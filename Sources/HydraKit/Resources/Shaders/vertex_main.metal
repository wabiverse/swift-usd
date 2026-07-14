#include <metal_stdlib>
using namespace metal;

struct VertexIn 
{
  float4 position [[attribute(0)]];
};

struct VertexOut 
{
  float4 position [[position]];
};

vertex VertexOut vertex_main(VertexIn in [[stage_in]]) 
{
  VertexOut out;
  out.position = in.position;
  return out;
}
