//
//  SMWindowController.swift
//  Sim
//
//  Created by Tobin Bell on 8/19/16.
//  Copyright © 2016 Tobin Bell. All rights reserved.
//

import Cocoa

class SMWindowController: NSWindowController {
    
    var simulation: SMSimulationView?
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.titleVisibility = .Hidden
    }
    
    @IBAction func toggleSimulationPressed(sender: NSButton) {
        //self.simulation?.toggleSimulationPressed(sender)
    }
    
    @IBAction func zoomPressed(sender: NSSegmentedControl) {
//        switch sender.selectedSegment {
//            case 0:
//                //self.simulation?.zoomOutPressed(sender, segment: 0)
//            case 2:
//                //self.simulation?.zoomInPressed(sender, segment: 2)
//            default:
//                //self.simulation?.zoomToFitPressed(sender, segment: 1)
//        }
    }
    
}
