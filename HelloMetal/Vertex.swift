//
//  Vertex.swift
//  HelloMetal
//
//  Created by John Yang on 20/06/16.
//
//

import Foundation

struct Vertex {
    var x, y, z: Float
    var r, g, b, a: Float
    
    func floatBuffer() -> [Float] {
        return [x, y, z, r, g, b, a]
    }
}
