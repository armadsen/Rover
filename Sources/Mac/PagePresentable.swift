//
//  PagePresentable.swift
//  Rover
//
//  Created by Andrew Madsen on 12/5/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Cocoa

protocol PagePresentable: class {
	var pageController: NSPageController? { get set }
}
