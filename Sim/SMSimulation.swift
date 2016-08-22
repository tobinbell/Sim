//
//  SMSimulation.swift
//  Sim
//
//  Created by Tobin Bell on 8/21/16.
//  Copyright © 2016 Tobin Bell. All rights reserved.
//

import Foundation

class SMSimulation {
    
    let period = 0.1
    
    weak var delegate: SMSimulationDelegate?
    var bodies = [SMBody]()
    private var timer = NSTimer()
    
    // Universal constants.
    let G: SMScalar = 6.674e-11
    
    func start() {
        timer = NSTimer(timeInterval: period, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
    }
    
    func stop() {
        timer.invalidate()
    }
    
    @objc func timerFired() {
        progress(by: period)
    }
    
    private func progress(by time: SMScalar) {
        
        // Use each body's acceleration to update its velocity,
        // and use its velocity to update its position.
        for i in 0 ..< bodies.count {
            let acceleration = bodies[i].acceleration
            let velocity = bodies[i].velocity
            let center = bodies[i].center
            bodies[i].velocity = velocity + acceleration * time
            bodies[i].center = center + velocity * time
        }
        
        delegate?.updatedBodies(for: self)
        
        // Now that our position has changed, update force and acceleration calculations.
        computeForces()
        computeAccelerations()
    }
    
    private func computeForces() {
        
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
                let gravitational = G * m1 * m2 / (r * r) * rv
                
                bodies[i].forces = [gravitational]
                bodies[j].forces = [-gravitational]
            }
        }
    }
    
    private func computeAccelerations() {
        
        // Loop over each body and compute its net force to determine its acceleration.
        for i in 0 ..< bodies.count {
            let forcesCount = SMScalar(bodies[i].forces.count)
            let net = bodies[i].forces.reduce(SMVector(), combine: { net, next in
                return net + next / forcesCount
            })
            
            bodies[i].acceleration = net / bodies[i].mass
        }
    }
}

protocol SMSimulationDelegate: class {
    func updatedBodies(for simulation: SMSimulation)
}