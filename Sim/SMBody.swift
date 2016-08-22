//
//  Body.swift
//  Sim
//
//  Created by Tobin Bell on 8/18/16.
//  Copyright © 2016 Tobin Bell. All rights reserved.
//

struct SMBody {
    
    enum Type {
        case Point, Rectangle, Ellipse
    }
    
    var type: Type = .Point
    var center: SMVector
    var velocity: SMVector
    var acceleration: SMVector
    var mass: SMScalar
    var forces: [SMVector]
}