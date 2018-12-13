//
//  Shaders.metal
//  MetalRTX
//
//  Created by Florian Schut on 13/12/2018.
//  Copyright © 2018 Florian Schut. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

vertex float4 basic_vertex_shader(const device packed_float3* vertex_array [[buffer(0)]],
                                  unsigned int vid [[ vertex_id ]])
{
    return float4(vertex_array[vid], 1.0f);
}

fragment half4 basic_fragment_shader()
{
    return half4(1.0);
}
