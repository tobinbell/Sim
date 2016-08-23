//
//  SMSimulation.swift
//  Sim
//
//  Created by Tobin Bell on 8/21/16.
//  Copyright © 2016 Tobin Bell. All rights reserved.
//

import Foundation

class SMSimulation {
    
    // Universal constants.
    let G: SMScalar = 6.674e-11
    
    weak var view: SMSimulationView?
    var bodies = [SMBody]()
    var isRunning = false
    
    func start() {
        isRunning = true
        
        let qos = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qos, 0)
        dispatch_async(backgroundQueue) {
            var previous = NSDate()
            while self.isRunning {
                let now = NSDate()
                let interval = now.timeIntervalSinceDate(previous)
                self.progress(by: interval)
                previous = now
            }
        }
    }
    
    func stop() {
        isRunning = false
    }
    
    private func progress(by time: SMScalar) {
        
        // Use each body's acceleration to update its velocity,
        // and use its velocity to update its position.
        for i in 0 ..< bodies.count {
            let acceleration = bodies[i].acceleration
            let velocity = bodies[i].velocity
            let center = bodies[i].center
            bodies[i].center = center + velocity * time
            bodies[i].velocity = velocity + acceleration * time
        }
        
        //delegate?.updatedBodies(for: self)
        view?.needsDisplay = true
        
        // Now that our position has changed, update force and acceleration calculations.
        computeForces()
        computeAccelerations()
    }
    
    private func computeForces() {
        
        // Empty all forces from previous simulation steps.
        for i in 0 ..< bodies.count {
            bodies[i].forces.removeAll()
        }
        
        // Loop over each pair of bodies in the simulation to compute
        // the forces that they exert on each other.
        // Supported forces: gravity.
        for i in 0 ..< bodies.count - 1 {
            for j in i + 1 ..< bodies.count {
                
                // Gravitational force.
                let m1 = bodies[i].mass
                let m2 = bodies[j].mass
                let rv = SMVector(from: bodies[i].center, to: bodies[j].center)
                let r = rv.magnitude
                let gravitational = G * m1 * m2 / (r * r) * rv.unit
                
                bodies[i].forces.append(gravitational)
                bodies[j].forces.append(-gravitational)
            }
        }
    }
    
    private func computeAccelerations() {
        
        // Loop over each body and compute its net force to determine its acceleration.
        for i in 0 ..< bodies.count {
            let net = bodies[i].forces.reduce(SMVector(), combine: +)
            bodies[i].acceleration = net / bodies[i].mass
        }
    }
}

//protocol SMSimulationDelegate: class {
//    func updatedBodies(for simulation: SMSimulation)
//}