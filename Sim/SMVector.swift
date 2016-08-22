//
//  SMVector.swift
//  Sim
//
//  Created by Tobin Bell on 8/18/16.
//  Copyright © 2016 Tobin Bell. All rights reserved.
//

import Foundation

struct SMVector {
    var x: SMScalar
    var y: SMScalar
    
    init() {
        self.x = 0
        self.y = 0
    }
    
    init(_ x: SMScalar, _ y: SMScalar) {
        self.x = x
        self.y = y
    }
    
    init(from a: SMVector = SMVector(), to b: SMVector) {
        self.x = b.x - a.x
        self.y = b.y - a.y
    }
    
    // Computed property. Returns the magnitude of a vector.
    var magnitude: SMScalar {
        return sqrt(x * x + y * y)
    }
    
    var unit: SMVector {
        let mag = magnitude
        return SMVector(x / mag, y / mag)
    }
}

// MARK: Adding

// Add two vectors together with the + operator.
func + (a: SMVector, b: SMVector) -> SMVector {
    return SMVector(a.x + b.x, a.y + b.y)
}

// Add one vector to another in place with the += operator.
func += (inout a: SMVector, b: SMVector) {
    a.x += b.x
    a.y += b.y
}

// Subtract two vectors with the - operator.
func - (a: SMVector, b: SMVector) -> SMVector {
    return SMVector(a.x - b.x, a.y - b.y)
}

// Subtract one vector from another in place with the -= operator.
func -= (inout a: SMVector, b: SMVector) {
    a.x -= b.x
    a.y -= b.y
}

// MARK: Multiplying

// Negate a vector using the - prefix operator.
prefix func - (a: SMVector) -> SMVector {
    return SMVector(-a.x, -a.y)
}

// Multiply a vector by a scalar using the * operator.
func * (a: SMVector, b: SMScalar) -> SMVector {
    return SMVector(a.x * b, a.y * b)
}

func * (a: SMScalar, b: SMVector) -> SMVector {
    return SMVector(a * b.x, a * b.y)
}

// Multiply a vector by a scalar in place using the *= operator.
func *= (inout a: SMVector, b: SMScalar) {
    a.x *= b
    a.y *= b
}

// Divide a vector by a scalar using the / operator.
func / (a: SMVector, b: SMScalar) -> SMVector {
    return SMVector(a.x / b, a.y / b)
}

// Divide a vector by a scalar in place using the /= operator.
func /= (inout a: SMVector, b: SMScalar) {
    a.x /= b
    a.y /= b
}

// Dot two vectors using the * operator.
func * (a: SMVector, b: SMVector) -> SMScalar {
    return a.x * b.x + a.y * b.y
}
