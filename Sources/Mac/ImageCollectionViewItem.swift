//
//  ImageCollectionViewItem.swift
//  Rover
//
//  Created by Andrew Madsen on 12/6/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Cocoa

class ImageCollectionViewItem: NSCollectionViewItem {

	override func prepareForReuse() {
		imageView?.image = #imageLiteral(resourceName: "MarsPlaceholder")
		
		super.prepareForReuse()
	}
    
}
