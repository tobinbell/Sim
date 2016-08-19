//
//  SMCamera.swift
//  Sim
//
//  Created by Tobin Bell on 8/18/16.
//  Copyright © 2016 Tobin Bell. All rights reserved.
//

class SMCamera {
    var center: SMPoint
    var zoom: SMScalar
    
    init(at center: SMPoint = SMPoint(), zoom: SMScalar) {
        self.center = center
        self.zoom = zoom
    }
}
