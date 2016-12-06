//
//  NSTouchBarProvider+Extras.swift
//  Rover
//
//  Created by Andrew Madsen on 12/5/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Cocoa

extension NSTouchBarProvider where Self : NSResponder {
	func invalidateTouchBar() {
		self.touchBar = nil
	}
}
