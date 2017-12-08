//
//  DebugView.swift
//  Rover
//
//  Created by Andrew Madsen on 12/5/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Cocoa

class DebugView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

		NSColor.green.set()
		dirtyRect.fill()
    }
    
}
