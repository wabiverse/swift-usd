/*
Copyright © 2022 Apple Inc.

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
