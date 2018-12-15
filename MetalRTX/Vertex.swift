//
//  Vertex.swift
//  MetalRTX
//
//  Created by Florian Schut on 13/12/2018.
//  Copyright © 2018 Florian Schut. All rights reserved.
//

import Foundation

struct Vertex{
    var x, y, z: Float
    var r, g, b, a: Float
	var s, t: Float
    
    func floatBuffer()->[Float]{
        return [x, y, z, r, g, b, a, s, t]
    }
}
