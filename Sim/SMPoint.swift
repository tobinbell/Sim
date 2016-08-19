//
//  SMPoint.swift
//  Sim
//
//  Created by Tobin Bell on 8/18/16.
//  Copyright © 2016 Tobin Bell. All rights reserved.
//

struct SMPoint {
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
    
    // MARK: Translation
    
    // Translate a point by a certain vector.
    func translated(by v: SMVector) -> SMPoint {
        return SMPoint(x + v.x, y + v.y)
    }
    
    // Translate a point in place by a given vector.
    mutating func translate(by v: SMVector) {
        x += v.x
        y += v.y
    }
}