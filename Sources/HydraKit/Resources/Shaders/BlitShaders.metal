/*
Copyright © 2022 Apple Inc.
Modifications Copyright © 2026 Wabi Foundation.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#include <metal_stdlib>
using namespace metal;

struct VertexOut
{
  float4 position [[ position ]];
  float2 texcoord;
};

vertex VertexOut vtxBlit(uint vid [[vertex_id]])
{
  // These vertices map a triangle to cover a fullscreen quad.
  const float4 vertices[] = {
    float4(-1, -1, 1, 1), // bottom left
    float4(3, -1, 1, 1),  // bottom right
    float4(-1, 3, 1, 1),  // upper left
  };
  
  const float2 texcoords[] = {
    float2(0.0, 0.0), // bottom left
    float2(2.0, 0.0), // bottom right
    float2(0.0, 2.0), // upper left
  };
  
  VertexOut out;
  out.position = vertices[vid];
  out.texcoord = texcoords[vid];
  return out;
}

fragment half4 fragBlitLinear(VertexOut in [[stage_in]], texture2d<float> tex[[texture(0)]])
{
  constexpr sampler s = sampler(address::clamp_to_edge);

  float4 pixel = tex.sample(s, in.texcoord);
  return half4(pixel);
}

// ---- selection outline -------------------------------------------------

struct OutlineUniforms
{
  int selectedPrimId;
  int selectedInstanceId;
  int outlineWidth;
  int useGroup;     // match via groupLUT (model pick), 0: match the id pair
  int groupCount;   // number of entries in groupLUT
  int selectAll;    // every prim is selected (outline the whole scene)
  int modelCount;   // number of entries in modelLUT (select-all)
  int _pad2;
  float4 outlineColor;
};

// ---- selection outline: jump-flood distance field --------------------------
//
// a viewport outline needs a clean, SOLID object mask (like a rasterized
// selection buffer) and then a smooth distance to a silhouette field.
//
// it is built as:
//   1. `jfaMask`              - resolve the noisy MSAA ids into a clean binary silhouette.
//   2. `jfaDilate`+`jfaErode` - a morphological close that fills the interior holes.
//   3. `jfaSeed`              - seed the boundary of the closed silhouette.
//   4. `jfaStep`              - jump-flood passes propagate the nearest boundary coordinate.
//   5. the fragment shader turns that distance into a smooth, uniform-width, anti-aliased
//      stroke centered on the silhouette.
// an invalid seed is stored as a negative coordinate.

constant float2 kInvalidSeed = float2(-1.0, -1.0);

// half-extent of the morphological close. fills interior holes up to
// 2 * kCloseRadius texels wide (the slivers left by the antialiased
// internal silhouettes) while leaving the true outer silhouette in
// place.
constant int kCloseRadius = 3;

// resolves the MSAA ids into a clean binary silhouette mask. a texel counts
// as selected when at least half its samples belong to the selection, which
// discards noisy MSAA ids into a clean binary silhouette. grouping either a
// single (primId, instanceId) pair (an instance / cell pick) or, for a model
// pick, any primId flagged in `groupLUT`.
kernel void jfaMask(texture2d_ms<int> primIdTex [[texture(0)]],
                    texture2d_ms<int> instanceIdTex [[texture(1)]],
                    texture2d<float, access::write> maskOut [[texture(2)]],
                    texture2d_ms<float> depthTex [[texture(3)]],
                    constant OutlineUniforms &u [[buffer(0)]],
                    device const int *groupLUT [[buffer(1)]],
                    uint2 gid [[thread_position_in_grid]])
{
  if (gid.x >= maskOut.get_width() || gid.y >= maskOut.get_height()) { return; }

  const uint samples = primIdTex.get_num_samples();
  uint hits = 0u;
  for (uint s = 0; s < samples; ++s) {
    // reject samples with no current-frame geometry,
    // the id AOVs are only overwritten where geometry
    // draws, so a cached pixel keeps a stale id, but
    // depth is always cleared to far (1.0), so this
    // drops any ghosting/artifacting outlines.
    if (depthTex.read(gid, s).r >= 1.0) { continue; }

    const int pid = primIdTex.read(gid, s).r;
    bool match;
    if (u.selectAll != 0) {
      match = (pid >= 0);
    } else if (u.useGroup != 0) {
      match = (pid >= 0 && pid < u.groupCount && groupLUT[pid] != 0);
    } else {
      const int iid = instanceIdTex.read(gid, s).r;
      match = (pid == u.selectedPrimId && iid == u.selectedInstanceId);
    }
    if (match) { ++hits; }
  }
  maskOut.write(float4(hits * 2u >= samples ? 1.0 : 0.0), gid);
}

// morphological dilate (max) of the mask by kCloseRadius.
// paired with the erode folded into `jfaSeed`, this fills
// any interior holes.
kernel void jfaDilate(texture2d<float, access::read> maskIn [[texture(0)]],
                      texture2d<float, access::write> maskOut [[texture(1)]],
                      uint2 gid [[thread_position_in_grid]])
{
  const int2 size = int2(maskIn.get_width(), maskIn.get_height());
  if (int(gid.x) >= size.x || int(gid.y) >= size.y) { return; }

  float v = 0.0;
  for (int dy = -kCloseRadius; dy <= kCloseRadius; ++dy) {
    for (int dx = -kCloseRadius; dx <= kCloseRadius; ++dx) {
      const int2 q = clamp(int2(gid) + int2(dx, dy), int2(0), size - 1);
      v = max(v, maskIn.read(uint2(q)).r);
    }
  }
  maskOut.write(float4(v), gid);
}

// morphological erode (min) of the dilated mask.
// completing the close/fill, to get a solid and
// hole-free silhouette of the selection.
kernel void jfaErode(texture2d<float, access::read> maskIn [[texture(0)]],
                     texture2d<float, access::write> maskOut [[texture(1)]],
                     uint2 gid [[thread_position_in_grid]])
{
  const int2 size = int2(maskIn.get_width(), maskIn.get_height());
  if (int(gid.x) >= size.x || int(gid.y) >= size.y) { return; }

  float v = 1.0;
  for (int dy = -kCloseRadius; dy <= kCloseRadius; ++dy) {
    for (int dx = -kCloseRadius; dx <= kCloseRadius; ++dx) {
      const int2 q = clamp(int2(gid) + int2(dx, dy), int2(0), size - 1);
      v = min(v, maskIn.read(uint2(q)).r);
    }
  }
  maskOut.write(float4(v), gid);
}

// seeds the jump-flood field with the silhouette boundary. an interior
// texel that touches the outside mask boundary and stores its own coord,
// everything outside the masked boundary is removed. seeding the boundary
// instead of every selected texel gives us a distance to the silhouette,
// which lets the outline sit centered on the edge of the mask.
kernel void jfaSeed(texture2d<float, access::read> maskIn [[texture(0)]],
                    texture2d<float, access::write> seedOut [[texture(1)]],
                    uint2 gid [[thread_position_in_grid]])
{
  const int2 size = int2(maskIn.get_width(), maskIn.get_height());
  if (int(gid.x) >= size.x || int(gid.y) >= size.y) { return; }

  bool boundary = false;
  if (maskIn.read(gid).r > 0.5) {
    const int2 offsets[4] = { int2(1, 0), int2(-1, 0), int2(0, 1), int2(0, -1) };
    for (int i = 0; i < 4; ++i) {
      const int2 q = clamp(int2(gid) + offsets[i], int2(0), size - 1);
      if (maskIn.read(uint2(q)).r <= 0.5) { boundary = true; break; }
    }
  }
  const float2 seed = boundary ? float2(gid) : kInvalidSeed;
  seedOut.write(float4(seed, 0.0, 0.0), gid);
}

// ---- select-all: per-object outlines ---------------------------------------
//
// "select all" (`A`) outlines every object individually, so the seed must
// include the borders between all of the different prims/objects, not just
// the union silhouette. each pixel is labeled with its model id where the
// value of (0 = background) and the jump-flood is seeded wherever that label
// changes. The morphological close (reusing jfaDilate/jfaErode on the mask),
// plus jfaLabelFill keeps the anti-aliased interior noise from reading as a
// bunch of extra internal borders.

// per-pixel model label: the depth-gated model id across the MSAA samples.
// also emits the texture that the morphological close/fill runs on.
kernel void jfaLabel(texture2d_ms<int> primIdTex [[texture(0)]],
                     texture2d_ms<float> depthTex [[texture(1)]],
                     texture2d<int, access::write> labelOut [[texture(2)]],
                     texture2d<float, access::write> presenceOut [[texture(3)]],
                     constant OutlineUniforms &u [[buffer(0)]],
                     device const int *modelLUT [[buffer(1)]],
                     uint2 gid [[thread_position_in_grid]])
{
  if (gid.x >= labelOut.get_width() || gid.y >= labelOut.get_height()) { return; }

  const uint samples = primIdTex.get_num_samples();
  int labels[16];
  uint n = 0u;
  for (uint s = 0; s < samples && n < 16u; ++s) {
    if (depthTex.read(gid, s).r >= 1.0) { continue; } // no current geometry
    const int pid = primIdTex.read(gid, s).r;
    labels[n++] = (pid >= 0 && pid < u.modelCount) ? modelLUT[pid] : 0;
  }

  // presence: a majority of samples hold geometry (for the silhouette).
  presenceOut.write(float4(n * 2u >= samples ? 1.0 : 0.0), gid);

  // label: the most common model id across samples.
  int best = 0;
  uint bestCount = 0u;
  for (uint i = 0; i < n; ++i) {
    uint c = 0u;
    for (uint j = 0; j < n; ++j) { if (labels[j] == labels[i]) { ++c; } }
    if (c > bestCount) { bestCount = c; best = labels[i]; }
  }
  labelOut.write(int4(best, 0, 0, 0), gid);
}

// fills the thin interior holes that the antialiased silhouettes punch through an
// object (label 0 inside the closed silhouette) with its neighbouring object's label,
// so they do not read as a bunch of extra internal borders.
kernel void jfaLabelFill(texture2d<int, access::read> labelIn [[texture(0)]],
                         texture2d<float, access::read> closedMask [[texture(1)]],
                         texture2d<int, access::write> labelOut [[texture(2)]],
                         uint2 gid [[thread_position_in_grid]])
{
  const int2 size = int2(labelIn.get_width(), labelIn.get_height());
  if (int(gid.x) >= size.x || int(gid.y) >= size.y) { return; }

  int label = labelIn.read(gid).r;
  if (label == 0 && closedMask.read(gid).r > 0.5) {
    for (int dy = -kCloseRadius; dy <= kCloseRadius; ++dy) {
      for (int dx = -kCloseRadius; dx <= kCloseRadius; ++dx) {
        const int2 q = clamp(int2(gid) + int2(dx, dy), int2(0), size - 1);
        label = max(label, labelIn.read(uint2(q)).r);
      }
    }
  }
  labelOut.write(int4(label, 0, 0, 0), gid);
}

// seeds the jump-flood with every object border.
// any internal texel that touches another object
// or the background mask is a boundary.
kernel void jfaLabelSeed(texture2d<int, access::read> labelIn [[texture(0)]],
                         texture2d<float, access::read> closedMask [[texture(1)]],
                         texture2d<float, access::write> seedOut [[texture(2)]],
                         uint2 gid [[thread_position_in_grid]])
{
  const int2 size = int2(labelIn.get_width(), labelIn.get_height());
  if (int(gid.x) >= size.x || int(gid.y) >= size.y) { return; }

  bool boundary = false;
  if (closedMask.read(gid).r > 0.5) {
    const int label = labelIn.read(gid).r;
    const int2 offsets[4] = { int2(1, 0), int2(-1, 0), int2(0, 1), int2(0, -1) };
    for (int i = 0; i < 4; ++i) {
      const int2 q = clamp(int2(gid) + offsets[i], int2(0), size - 1);
      const bool nInside = closedMask.read(uint2(q)).r > 0.5;
      if (!nInside || labelIn.read(uint2(q)).r != label) { boundary = true; break; }
    }
  }
  seedOut.write(float4(boundary ? float2(gid) : kInvalidSeed, 0.0, 0.0), gid);
}

// one jump-flood pass: each texel gets the nearest valid seed among
// its neighbours `step` texels away and its own current seed. running
// with (step = 2^k..1) resolves the nearest silhouette texel for every
// pixel.
kernel void jfaStep(texture2d<float, access::read> seedIn [[texture(0)]],
                    texture2d<float, access::write> seedOut [[texture(1)]],
                    constant uint &step [[buffer(0)]],
                    uint2 gid [[thread_position_in_grid]])
{
  const int2 size = int2(seedIn.get_width(), seedIn.get_height());
  if (int(gid.x) >= size.x || int(gid.y) >= size.y) { return; }

  float2 best = seedIn.read(gid).xy;
  float bestDist = best.x < 0.0 ? 1e20 : distance(float2(gid), best);

  for (int dy = -1; dy <= 1; ++dy) {
    for (int dx = -1; dx <= 1; ++dx) {
      if (dx == 0 && dy == 0) { continue; }
      const int2 q = int2(gid) + int2(dx, dy) * int(step);
      if (q.x < 0 || q.y < 0 || q.x >= size.x || q.y >= size.y) { continue; }
      const float2 seed = seedIn.read(uint2(q)).xy;
      if (seed.x < 0.0) { continue; }
      const float d = distance(float2(gid), seed);
      if (d < bestDist) { bestDist = d; best = seed; }
    }
  }
  seedOut.write(float4(best, 0.0, 0.0), gid);
}

// composites the color AOV with the outline read from the jump-flood field.
// distance to the nearest silhouette texel drives a smooth, uniform-width,
// antialiased 'halo' that hugs the outside of the selection.
fragment half4 fragSelectionOutline(VertexOut in [[stage_in]],
                                    texture2d<float> colorTex [[texture(0)]],
                                    texture2d<float> seedTex [[texture(1)]],
                                    constant OutlineUniforms &u [[buffer(0)]])
{
  constexpr sampler s = sampler(address::clamp_to_edge);
  float4 color = colorTex.sample(s, in.texcoord);

  const int2 size = int2(int(seedTex.get_width()), int(seedTex.get_height()));
  const int2 p = clamp(int2(in.texcoord * float2(size)), int2(0), size - 1);

  const float2 seed = seedTex.read(uint2(p)).xy;
  if (seed.x < 0.0) { return half4(color); }   // no silhouette within the band

  // a stroke `outlineWidth` texels wide is centred on the silhouette, so it
  // reads as a solid line hugging the selection rather than a one-sided halo,
  // and a 1-texel smooth falloff anti-aliases both edges.
  const float dist = distance(float2(p), seed);
  const float halfWidth = float(max(u.outlineWidth, 1)) * 0.5;
  const float coverage = 1.0 - smoothstep(halfWidth - 0.5, halfWidth + 0.5, dist);
  if (coverage <= 0.0) { return half4(color); }

  const float a = coverage * u.outlineColor.a;
  return half4(float4(mix(color.rgb, u.outlineColor.rgb, a), color.a));
}

// reads sample 0 of the MSAA id AOVs at one texel and writes
// (primId, instanceId) out, a blit cannot copy a single sample
// of a multisampled texture, so the selection readback has to
// go through this instead.
kernel void readSelectionId(texture2d_ms<int> primIdTex [[texture(0)]],
                            texture2d_ms<int> instanceIdTex [[texture(1)]],
                            device int2 *out [[buffer(0)]],
                            constant uint2 &coord [[buffer(1)]],
                            uint tid [[thread_position_in_grid]])
{
  if (tid != 0) { return; }
  out[0] = int2(primIdTex.read(coord, 0).r, instanceIdTex.read(coord, 0).r);
}
