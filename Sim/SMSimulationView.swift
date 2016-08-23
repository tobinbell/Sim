//
//  SMSimulationView.swift
//  Sim
//
//  Created by Tobin Bell on 8/18/16.
//  Copyright © 2016 Tobin Bell. All rights reserved.
//

import Cocoa

class SMSimulationView: NSView {
    
    // MARK: Configuration
    
    // Colors of various UI elements.
    private let backgroundColor = NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
    private let originColor = NSColor(red: 0.9, green: 0, blue: 0, alpha: 1)
    private let axisColor = NSColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
    private let gridColor = NSColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)
    private let crossHairColor = NSColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1)
    
    // Dimensions.
    private let originRadius: CGFloat = 4
    private let axisLineWidth: CGFloat = 1
    private let gridLineWidth: CGFloat = 1
    private let crossHairLineWidth: CGFloat = 1
    
    // The simulation to be rendered.
    var simulation = SMSimulation() {
        didSet {
            simulation.view = self
        }
        willSet {
            if simulation.view == self {
                simulation.view = nil
            }
        }
    }
    
    // A camera object, representing the view point to display.
    var camera = SMCamera(zoom: 20) {
        didSet {
            // Whenever the viewpoint has changed, redraw.
            self.needsDisplay = true
        }
    }
    
    // Initializers. Due to Cocoa's setup, these two initializers are required
    // to ensure that all custom setup code runs when the view is created.
    // Both initializers simply call the custom setup() method.
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: Setup
    
    // Perform all setup required for the view.
    // This mostly passes off the setup work to more specialized methods.
    private func setup() {
        updateGridSpacing()
        setupMouseInteraction()
    }
    
    // MARK: Mouse Interaction
    
    private var mouseLocation: CGPoint? {
        didSet {
            // Whenever the mouse position changes, redraw.
            self.needsDisplay = true
        }
    }
    
    private func setupMouseInteraction() {
        
        // Create the tracking area to handle mouse moved events.
        // This will be used to update the cross hair.
        //
        // Note: we specify the .InVisibleRect option because the self.bounds is
        // not yet correctly defined when this method runs.
        let mouseTracker = NSTrackingArea(rect: self.bounds,
                                          options: [.InVisibleRect, .ActiveInActiveApp, .MouseMoved],
                                          owner: self,
                                          userInfo: nil)
        self.addTrackingArea(mouseTracker)
    }
    
    // Pan the center of the camera in response to the scroll wheel.
    override func scrollWheel(event: NSEvent) {
        
        // Convert graphical deltas to simulation-space deltas.
        let simulationDeltaX = simulationLength(from: event.scrollingDeltaX)
        let simulationDeltaY = simulationLength(from: event.scrollingDeltaY)
        let simulationDelta = SMVector(-simulationDeltaX, simulationDeltaY)
        
        camera.center += simulationDelta
    }
    
    // Update the mouse location (and indirectly, the crosshair) when the mouse moves.
    // This method is only run because of the NSTrackingArea that is created in the
    // setupMouseInteraction() method above.
    override func mouseMoved(event: NSEvent) {
        // Convert the click point to our own coordinate system from the window's coordinates.
        mouseLocation = self.convertPoint(event.locationInWindow, fromView: nil)
    }
    
    // MARK: Coordinate Conversions
    
    // Convert a physical distance in the simulation (as an SMScalar) to a
    // length on the screen (as a CGFloat) based on the value of the camera's zoom.
    func graphicsLength(from l: SMScalar) -> CGFloat {
        return CGFloat(l * self.camera.zoom)
    }
    
    // Convert a length on the screen (as a CGFloat) to a distance in the simulation.
    func simulationLength(from l: CGFloat) -> SMScalar {
        return SMScalar(l) / self.camera.zoom
    }
    
    // Convert an x coordinate from simulation space to screen space.
    func graphicsX(from x: SMScalar) -> CGFloat {
        return self.bounds.midX + CGFloat((x - self.camera.center.x) * self.camera.zoom)
    }
    
    // Convert an x coordinate from graphics space to simulation space.
    func simulationX(from x: CGFloat) -> SMScalar {
        return SMScalar(x - self.bounds.midX) / self.camera.zoom + self.camera.center.x
    }
    
    // Convert a y coordinate from simulation space to screen space.
    func graphicsY(from y: SMScalar) -> CGFloat {
        return self.bounds.midY + CGFloat((y - self.camera.center.y) * self.camera.zoom)
    }
    
    // Convert a y coordinate from graphics space to simulation space.
    func simulationY(from y: CGFloat) -> SMScalar {
        return SMScalar(y - self.bounds.midY) / self.camera.zoom + self.camera.center.y
    }
    
    // Convert a point from simulation space to screen space.
    func graphicsPoint(from p: SMVector) -> CGPoint {
        return CGPoint(x: graphicsX(from: p.x), y: graphicsY(from: p.y))
    }
    
    // Convert a point from simulation space to screen space.
    func simulationPoint(from p: CGPoint) -> SMVector {
        return SMVector(simulationX(from: p.x), simulationY(from: p.y))
    }
    
    // MARK: Environmental Drawing
    
    // Cache the grid spacing, so we don't need to calculate it every time.
    private var oldZoom: SMScalar = 0
    private var gridSpacing: SMScalar = 0
    
    // Recalculate the grid spacing.
    private func updateGridSpacing() {
        
        // Do nothing if the zoom has not been changed.
        if camera.zoom == oldZoom { return }
        
        oldZoom = camera.zoom
        
        // Find the best grid spacing to use, assuming it must fit a given simulation-space length.
        // We determine this simulation length based on a fixed graphical length (60 points).
        
        let minLength = simulationLength(from: 60)
        let log = log10(minLength)
        let magnitude = floor(log)
        var step = log - magnitude
        
        // Bring the step of the log up to the nearest 2, 5, or 10.
        // Example:
        //     17 -> 20
        //     213 -> 500
        //     0.7 -> 1
        //     6000 -> 10000
        switch step {
        case log10(1) ..< log10(2):
            step = log10(2)
        case log10(2) ..< log10(5):
            step = log10(5)
        default:
            step = 1
        }
        
        gridSpacing = pow(10, magnitude + step)
    }
    
    // Convert a coordinate value to a displayable string.
    // If the value is sufficiently normal, display it in decimal.
    // Otherwise, use short scientific notation.
    func displayableString(for coordinate: SMScalar) -> String {
        
        let absoluteCoordinate = abs(coordinate)
        if absoluteCoordinate < 0.1 / self.camera.zoom { return "0" }
        
        // We consider "normal" to be between 1/1000 and 10000.
        let formatter = NSNumberFormatter()
        if absoluteCoordinate >= 0.001 && absoluteCoordinate < 10000 {
            formatter.numberStyle = .DecimalStyle
            return formatter.stringFromNumber(coordinate) ?? "NaN"
        }
        
        // Otherwise, use scientific notation.
        formatter.numberStyle = .ScientificStyle
        formatter.exponentSymbol = "e"
        return formatter.stringFromNumber(coordinate) ?? "NaN"
    }
    
    // Convert a coordinate point to a displayable string.
    // If a coordinate value is sufficiently normal, display it in decimal.
    // Otherwise, use short scientific notation.
    func displayableString(for point: SMVector) -> String {
        return "\(displayableString(for: point.x)), \(displayableString(for: point.y))"
    }
    
    // Draw the simulation. This performs utility drawing, like the background and coordinates,
    // as well as drawing the actual bodies of the simulation.
    override func drawRect(rect: NSRect) {
        super.drawRect(rect)
        
        drawBackground()
        drawCoordinates()
        drawBodies()
        drawMouse()
    }
    
    // Draws the background of the simulation view.
    // This is just a dark gray fill.
    private func drawBackground() {
        // Fill the bounds with the background color.
        backgroundColor.setFill()
        NSRectFill(self.bounds)
    }
    
    // Label a graphics-space point with a given string.
    private func drawLabel(text: String, at point: CGPoint, using color: NSColor = .whiteColor()) {
        
        let label = text as NSString
        let size = label.sizeWithAttributes([:])
        
        let x = point.x + 8
        let y = point.y + 6
        let labelRect = CGRect(origin: CGPoint(x: x, y: y), size: size)
        
        // Draw the label only if it is on screen.
        if labelRect.intersects(bounds) {
            label.drawWithRect(labelRect, options: [], attributes: [NSForegroundColorAttributeName: color])
        }
    }
    
    // Annotate a graphics-space point with a text-based annotation.
    // Similar to drawLabel() above, but this method will shift the annotation
    // around the given point when the point gets near an edge.
    private func drawAnnotation(text: String, at point: CGPoint, using color: NSColor = .whiteColor()) {
        let label = text as NSString
        let size = label.sizeWithAttributes([:])
        
        var x = point.x + 8
        var y = point.y + 6
        
        // Move the label over if it is too close to either edge (right or top).
        if x + size.width > bounds.maxX {
            x = point.x - size.width - 8
        }
        if y + size.height > bounds.maxY {
            y = point.y - size.height
        }
        let labelRect = CGRect(origin: CGPoint(x: x, y: y), size: size)
        
        // Draw the label only if it is on screen.
        if labelRect.intersects(bounds) {
            label.drawWithRect(labelRect, options: [], attributes: [NSForegroundColorAttributeName: color])
        }
    }
    
    // Draw a label at a point that clips to the bounds of the view. If the point scrolls
    // off screen, the label will remain at the edge of the view.
    private func drawClipping(text: String, at point: CGPoint, using color: NSColor = .whiteColor()) {
        let label = text as NSString
        let size = label.sizeWithAttributes([:])
        
        var x = point.x + 8
        var y = point.y + 6
        
        // Move the label over if it is too close to either edge (right or top).
        if x + size.width > bounds.maxX {
            x = bounds.maxX - size.width - 8
        }
        if y + size.height > bounds.maxY {
            y = bounds.maxY - size.height
        }
        let labelRect = CGRect(origin: CGPoint(x: x, y: y), size: size)
        
        // Draw the label only if it is on screen.
        if labelRect.intersects(bounds) {
            label.drawWithRect(labelRect, options: [], attributes: [NSForegroundColorAttributeName: color])
        }
    }
    
    // Draw a clipping label, but only clipping in the horizontal direction.
    private func drawHorizontalClipping(text: String, at point: CGPoint, using color: NSColor = .whiteColor()) {
        let label = text as NSString
        let size = label.sizeWithAttributes([:])
        
        var x = point.x + 8
        let y = point.y + 6
        
        // Move the label over if it is too close to either edge (right or top).
        if x + size.width > bounds.maxX {
            x = bounds.maxX - size.width - 8
        }
        let labelRect = CGRect(origin: CGPoint(x: x, y: y), size: size)
        
        // Draw the label only if it is on screen.
        if labelRect.intersects(bounds) {
            label.drawWithRect(labelRect, options: [], attributes: [NSForegroundColorAttributeName: color])
        }
    }
    
    // Draw a clipping label, but only clipping in the vertical direction.
    private func drawVerticalClipping(text: String, at point: CGPoint, using color: NSColor = .whiteColor()) {
        let label = text as NSString
        let size = label.sizeWithAttributes([:])
        
        let x = point.x + 8
        var y = point.y + 6
        
        // Move the label over if it is too close to either edge (right or top).
        if y + size.height > bounds.maxY {
            y = bounds.maxY - size.height
        }
        let labelRect = CGRect(origin: CGPoint(x: x, y: y), size: size)
        
        // Draw the label only if it is on screen.
        if labelRect.intersects(bounds) {
            label.drawWithRect(labelRect, options: [], attributes: [NSForegroundColorAttributeName: color])
        }
    }
    
    // Draws the basic coordinate space graphics.
    // The origin is represented by a red circle.
    private func drawCoordinates() {
        
        gridColor.setStroke()
        
        // Vertical gridlines.
        let leftX = simulationX(from: self.bounds.minX)
        var gridX = floor(leftX / gridSpacing) * gridSpacing
        while true {
            
            // Draw gridlines and move over until we run off the side of the screen.
            gridX = (round(gridX / gridSpacing) + 1) * gridSpacing
            let gridXScreen = graphicsX(from: gridX)
            if gridXScreen > self.bounds.maxX { break }
            
            let gridPath = NSBezierPath()
            gridPath.moveToPoint(NSPoint(x: gridXScreen, y: self.bounds.minY))
            gridPath.lineToPoint(NSPoint(x: gridXScreen, y: self.bounds.maxY))
            gridPath.lineWidth = gridLineWidth
            gridPath.stroke()
        }
        
        // Horizontal gridlines.
        let bottomY = simulationY(from: self.bounds.minY)
        var gridY = floor(bottomY / gridSpacing) * gridSpacing
        while true {
            
            // Draw gridlines and move up until we run off the top of the screen.
            gridY = (round(gridY / gridSpacing) + 1) * gridSpacing
            let gridYScreen = graphicsY(from: gridY)
            if gridYScreen > self.bounds.maxY { break }
            
            let gridPath = NSBezierPath()
            gridPath.moveToPoint(NSPoint(x: self.bounds.minX, y: gridYScreen))
            gridPath.lineToPoint(NSPoint(x: self.bounds.maxX, y: gridYScreen))
            gridPath.lineWidth = gridLineWidth
            gridPath.stroke()
        }
        
        // Calculate axis geometry.
        let xAxisY = graphicsY(from: 0)
        let yAxisX = graphicsX(from: 0)
        
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
        let origin = SMVector()
        let originPoint = graphicsPoint(from: origin)
        let originRect = CGRect(x: originPoint.x - originRadius,
                                y: originPoint.y - originRadius,
                                width: 2 * originRadius,
                                height: 2 * originRadius)
        
        // If the origin is on screen, draw it.
        if originRect.intersects(self.bounds) {
            originColor.setFill()
            let originPath = NSBezierPath(ovalInRect: originRect)
            originPath.fill()
        }
        
        // Lastly, we will draw the coordinate value labels, using the axis color to do so.
        
        // Vertical gridline labels.
        gridX = floor(leftX / gridSpacing) * gridSpacing
        while true {
            
            // Don't display the coordinate 0.
            if gridX == 0 {
                gridX = gridSpacing
                continue
            }
            
            let gridXScreen = graphicsX(from: gridX)
            if gridXScreen > self.bounds.maxX { break }
            
            let label = displayableString(for: gridX)
            drawVerticalClipping(label, at: CGPoint(x: gridXScreen, y: graphicsY(from: 0)))
            
            gridX = (round(gridX / gridSpacing) + 1) * gridSpacing
        }
        
        // Horizontal gridline labels.
        gridY = floor(bottomY / gridSpacing) * gridSpacing
        while true {
            
            // Don't display the coordinate 0.
            if gridY == 0 {
                gridY = gridSpacing
                continue
            }
            
            let gridYScreen = graphicsY(from: gridY)
            if gridYScreen > self.bounds.maxY { break }
            
            let label = displayableString(for: round(gridY / self.gridSpacing) * self.gridSpacing)
            drawHorizontalClipping(label, at: CGPoint(x: graphicsX(from: 0), y: gridYScreen))
            
            gridY = (round(gridY / gridSpacing) + 1) * gridSpacing
        }
        
        drawLabel("O", at: graphicsPoint(from: SMVector()), using: originColor)
    }
    
    // Draw the simulation bodies.
    private func drawBodies() {
        
        NSColor.yellowColor().setFill()
        
        for body in simulation.bodies {
            let center = graphicsPoint(from: body.center)
            let rect = CGRect(x: center.x - 3, y: center.y - 3, width: 6, height: 6)
            if rect.intersects(self.bounds) {
                let path = NSBezierPath(ovalInRect: rect)
                path.fill()
            }
        }
    }
    
    // Draws mouse-dependent elements like the cross hair and coordinate labels.
    private func drawMouse() {
        if let location = self.mouseLocation {
            crossHairColor.colorWithAlphaComponent(0.5).setStroke()
            
            let horizontal = NSBezierPath()
            horizontal.moveToPoint(CGPoint(x: self.bounds.minX, y: location.y))
            horizontal.lineToPoint(CGPoint(x: self.bounds.maxX, y: location.y))
            horizontal.lineWidth = crossHairLineWidth
            horizontal.stroke()
            
            let vertical = NSBezierPath()
            vertical.moveToPoint(CGPoint(x: location.x, y: self.bounds.minY))
            vertical.lineToPoint(CGPoint(x: location.x, y: self.bounds.maxY))
            vertical.lineWidth = crossHairLineWidth
            vertical.stroke()
            
            let label = displayableString(for: simulationPoint(from: location))
            drawAnnotation(label, at: location, using: crossHairColor)
        }
    }
}
