//
//  SMSimulation.swift
//  Sim
//
//  Created by Tobin Bell on 8/18/16.
//  Copyright © 2016 Tobin Bell. All rights reserved.
//

import Cocoa

class SMSimulation: NSView {
    
    private var bodies = [SMBody]()
    private var camera = SMCamera(zoom: 5)
    
    private var panRecognizer: NSPanGestureRecognizer!
    
    override init(frame: NSRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setup() {
//        self.acceptsTouchEvents = true
        let magnificationRecognizer = NSMagnificationGestureRecognizer(target: self, action: #selector(viewMagnified))
    }
    
    override func drawRect(rect: NSRect) {
        super.drawRect(rect)
        
        
        drawBackground()
        drawCoordinates()
        
//        for body in bodies {
//            
//        }
    }
    
    // Draws the background of the simulation view.
    // This is just a dark gray fill.
    private func drawBackground() {
        
        // Background config.
        let backgroundColor = NSColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
        
        // Fill the bounds with the background color.
        backgroundColor.setFill()
        NSRectFill(self.bounds)
    }
    
    // Draws the basic coordinate space graphics.
    // The origin is represented by a red circle.
    private func drawCoordinates() {
        
        // Axis config.
        let originColor = NSColor(red: 0.75, green: 0, blue: 0, alpha: 1)
        let axisColor = NSColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        let gridColor = NSColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        let originRadius: CGFloat = 4
        let axisLineWidth: CGFloat = 1
        let gridLineWidth: CGFloat = 1
        
        // Calculate grid geometry.
        // Grid lines should never be closer than 100 points apart, so we find the best match based on the camera's zoom.
        let gridSpacing = pow(10, 1 - floor(log10(self.camera.zoom)))
        
        gridColor.setStroke()
        
        // Vertical gridlines.
        let leftX = self.camera.center.x - SMScalar(self.bounds.midX) / self.camera.zoom
        var gridX = floor(leftX / gridSpacing) * gridSpacing
        
        while true {
            // Draw gridlines and move over until we run off the side of the screen.
            gridX += gridSpacing
            let gridXScreen = self.bounds.midX + CGFloat((gridX - self.camera.center.x) * self.camera.zoom)
            if gridXScreen > self.bounds.maxX { break }
            
            let gridPath = NSBezierPath()
            gridPath.moveToPoint(NSPoint(x: gridXScreen, y: self.bounds.minY))
            gridPath.lineToPoint(NSPoint(x: gridXScreen, y: self.bounds.maxY))
            gridPath.lineWidth = gridLineWidth
            gridPath.stroke()
        }
        
        // Horizontal gridlines.
        let bottomY = self.camera.center.y - SMScalar(self.bounds.midY) / self.camera.zoom
        var gridY = floor(bottomY / gridSpacing) * gridSpacing
        
        while true {
            // Draw gridlines and move up until we run off the top of the screen.
            gridY += gridSpacing
            let gridYScreen = self.bounds.midY + CGFloat((gridY - self.camera.center.y) * self.camera.zoom)
            if gridYScreen > self.bounds.maxY { break }
            
            let gridPath = NSBezierPath()
            gridPath.moveToPoint(NSPoint(x: self.bounds.minX, y: gridYScreen))
            gridPath.lineToPoint(NSPoint(x: self.bounds.maxX, y: gridYScreen))
            gridPath.lineWidth = gridLineWidth
            gridPath.stroke()
        }
        
        // Calculate axis geometry.
        let xAxisY = self.bounds.midY - CGFloat(self.camera.center.y * self.camera.zoom)
        let yAxisX = self.bounds.midX - CGFloat(self.camera.center.x * self.camera.zoom)
        
        axisColor.setStroke()
        
        // X axis. If the X axis is on screen, draw it.
        if xAxisY + axisLineWidth / 2 > self.bounds.minY && xAxisY - axisLineWidth / 2 < self.bounds.maxY {
            let axisPath = NSBezierPath()
            axisPath.moveToPoint(NSPoint(x: self.bounds.minX, y: xAxisY))
            axisPath.lineToPoint(NSPoint(x: self.bounds.maxX, y: xAxisY))
            axisPath.lineWidth = axisLineWidth
            axisPath.stroke()
        }
        
        // Y axis. If the Y axis is on screen, draw it.
        if yAxisX + axisLineWidth / 2 > self.bounds.minX && yAxisX - axisLineWidth / 2 < self.bounds.maxX {
            let axisPath = NSBezierPath()
            axisPath.moveToPoint(NSPoint(x: yAxisX, y: self.bounds.minY))
            axisPath.lineToPoint(NSPoint(x: yAxisX, y: self.bounds.maxY))
            axisPath.lineWidth = axisLineWidth
            axisPath.stroke()
        }
        
        // Calculate origin geometry.
        let originX = self.bounds.midX - CGFloat(self.camera.center.x * self.camera.zoom)
        let originY = self.bounds.midY - CGFloat(self.camera.center.y * self.camera.zoom)
        let originRect = NSRect(x: originX - originRadius,
                                y: originY - originRadius,
                                width: 2 * originRadius,
                                height: 2 * originRadius)
        
        // If the origin is on screen, draw it.
        if originRect.intersects(self.bounds) {
            originColor.setFill()
            let originPath = NSBezierPath(ovalInRect: originRect)
            originPath.fill()
        }
    }
    
    // MARK: Scrolling the View
    
    override func scrollWheel(event: NSEvent) {
        let worldDeltaX = SMScalar(event.scrollingDeltaX) / self.camera.zoom
        let worldDeltaY = SMScalar(event.scrollingDeltaY) / self.camera.zoom
        let worldDelta = SMVector(-worldDeltaX, worldDeltaY)
        self.camera.center.translate(by: worldDelta)
        self.needsDisplay = true
    }
    
    func viewMagnified(sender: NSGestureRecognizer) {
        Swift.print("hi")
    }
}
