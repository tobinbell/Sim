//
//  SMCamera.swift
//  Sim
//
//  Created by Tobin Bell on 8/18/16.
//  Copyright © 2016 Tobin Bell. All rights reserved.
//

struct SMCamera {
    var center: SMVector
    var zoom: SMScalar
    
    init(at center: SMVector = SMVector(), zoom: SMScalar = 1) {
        self.center = center
        self.zoom = zoom
    }
    
    mutating func zoomIn(by factor: SMScalar = 1.25) {
        zoom *= factor
    }
    
    mutating func zoomOut(by factor: SMScalar = 1.25) {
        zoom /= factor
    }
}
