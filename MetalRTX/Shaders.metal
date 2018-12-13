//
//  Shaders.metal
//  MetalRTX
//
//  Created by Florian Schut on 13/12/2018.
//  Copyright © 2018 Florian Schut. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn{
    packed_float3 position;
    packed_float4 color;
};

struct VertexOut{
    float4 position [[position]];
    float4 color;
};

struct Uniforms{
    float4x4 modelMatrix;
    float4x4 projectionMatrix;
};

vertex VertexOut basic_vertex_shader(const device VertexIn* vertex_array [[buffer(0)]],
                                     const device Uniforms& Uniforms [[buffer(1)]],
                                  unsigned int vid [[ vertex_id ]])
{
    VertexIn in = vertex_array[vid];
    
    VertexOut out;
    out.position = Uniforms.projectionMatrix * Uniforms.modelMatrix * float4(in.position, 1.0f);
    out.color = in.color;
    
    return out;
}

fragment half4 basic_fragment_shader(VertexOut vertexOutput [[stage_in]])
{
    return half4(vertexOutput.color);
    
}
