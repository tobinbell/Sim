//
//  SMSimulationController.swift
//  Sim
//
//  Created by Tobin Bell on 8/18/16.
//  Copyright © 2016 Tobin Bell. All rights reserved.
//

import Cocoa

class SMSimulationController: NSViewController {
    
    // The simulation model.
    let simulation = SMSimulation()
    var simulationView: SMSimulationView!
    
    override func viewDidLoad() {
        simulationView = view as? SMSimulationView
        simulationView.simulation = simulation
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        simulation.bodies.append(SMBody(type: .Point, center: SMVector(10, 0), velocity: SMVector(0, 10), acceleration: SMVector(), mass: 59934072520228, forces: []))
        simulation.bodies.append(SMBody(type: .Point, center: SMVector(-10, 0), velocity: SMVector(0, -10), acceleration: SMVector(), mass: 59934072520228, forces: []))
        simulation.bodies.append(SMBody(type: .Point, center: SMVector(15, 0), velocity: SMVector(-1, 0.3), acceleration: SMVector(), mass: 59934072520228, forces: []))
        simulation.start()
    }

}

