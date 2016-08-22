//
//  SMSimulation.swift
//  Sim
//
//  Created by Tobin Bell on 8/21/16.
//  Copyright © 2016 Tobin Bell. All rights reserved.
//

import Foundation

class SMSimulation {
    
    var bodies = [SMBody]()
    
    private func progress(by time: SMScalar) {
        
    }
    
    private func computeForces() {
        
        // Loop over each body in the simulation to compute its effects on other bodies.
        // Supported forces: gravity.
        for body in bodies {
            body.forces.removeAll()
        }
    }
    
    
    
}