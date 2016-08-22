//
//  SMForce.swift
//  Sim
//
//  Created by Tobin Bell on 8/21/16.
//  Copyright © 2016 Tobin Bell. All rights reserved.
//

struct SMForce {
    
    enum Type {
        case Gravitational
    }
    
    let type: Type
    let value: SMVector
    
    init(_ type: Type, value: SMVector) {
        self.type = type
        self.value = value
    }
}
