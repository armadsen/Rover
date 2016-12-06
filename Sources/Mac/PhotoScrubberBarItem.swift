//
//  PhotoScrubberBarItem.swift
//  Rover
//
//  Created by Andrew Madsen on 12/5/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Cocoa

class PhotoScrubberBarItem: NSCustomTouchBarItem, NSScrubberDataSource, NSScrubberFlowLayoutDelegate {
	
	private static let itemViewIdentifier = "ImageItemViewIdentifier"
	
	init(identifier: NSTouchBarItemIdentifier, photosProvider: PhotosProvider = PhotosProvider.sharedProvider) {
		self.photosProvider = photosProvider
		
		super.init(identifier: identifier)
		
		let scrubber = NSScrubber()
		scrubber.register(ThumbnailItemView.self, forItemIdentifier: PhotoScrubberBarItem.itemViewIdentifier)
		scrubber.mode = .free
		scrubber.selectionBackgroundStyle = .roundedBackground
		scrubber.delegate = self
		scrubber.dataSource = self
		
		self.view = scrubber
	}
	
	required init?(coder: NSCoder) {
		self.photosProvider = PhotosProvider.sharedProvider
		super.init(coder: coder)
	}
	
	// MARK: Overridden
	
	// MARK: Public Methods
	
	var scrubber: NSScrubber? {
		return view as? NSScrubber
	}
	
	// MARK: Actions
	
	// MARK: NSScrubberDataSource
	
	func numberOfItems(for scrubber: NSScrubber) -> Int {
		return photosProvider.photoReferences.count
	}
	
	func scrubber(_ scrubber: NSScrubber, viewForItemAt index: Int) -> NSScrubberItemView {
		let itemView = scrubber.makeItem(withIdentifier: PhotoScrubberBarItem.itemViewIdentifier, owner: nil) as! ThumbnailItemView
		let photoRef = photosProvider.photoReferences[index]
		itemView.image = nil
		photosProvider.image(for: photoRef) { image in
			itemView.image = image
		}
		return itemView
	}
	
	// MARK: Private Methods
	
	// MARK: Public Properties
	
	// MARK: Private Properties
	
	private let photosProvider: PhotosProvider
	
	// MARK: Outlets

}
