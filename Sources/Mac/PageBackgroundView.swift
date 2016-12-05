//
//  PageBackgroundView.swift
//  Rover
//
//  Created by Andrew Madsen on 12/5/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Cocoa

class PageBackgroundView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let path = NSBezierPath(roundedRect: bounds, xRadius: 5, yRadius: 5)
		path.lineWidth = 1.0
		
		NSColor.white.set()
		path.fill()
    }
	
	override var isOpaque: Bool { return false }
    
}
