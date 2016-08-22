//
//  SMSimulationController.swift
//  Sim
//
//  Created by Tobin Bell on 8/18/16.
//  Copyright © 2016 Tobin Bell. All rights reserved.
//

import Cocoa

class SMSimulationController: NSViewController, SMSimulationDelegate {
    
    // The simulation model.
    let simulation = SMSimulation()
    var simulationView: SMSimulationView!
    
    override func viewDidLoad() {
        simulationView = view as? SMSimulationView
        simulation.delegate = self
    }
    
    func updatedBodies(for simulation: SMSimulation) {
        simulationView.needsDisplay = true
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        if let windowController = self.view.window?.windowController as? SMWindowController,
            simulation = self.view as? SMSimulationView {
            windowController.simulation = simulation
        }
    }

}

