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
	
	init(identifier: NSTouchBarItemIdentifier, dataSource: MarsPhotosDataSource) {
		self.dataSource = dataSource
		
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
		self.dataSource = MarsPhotosDataSource()
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
		return dataSource.photoReferences.count
	}
	
	func scrubber(_ scrubber: NSScrubber, viewForItemAt index: Int) -> NSScrubberItemView {
		let itemView = scrubber.makeItem(withIdentifier: PhotoScrubberBarItem.itemViewIdentifier, owner: nil) as! ThumbnailItemView
		let photoRef = dataSource.photoReferences[index]
		if let imageData = PhotoCache.sharedCache.imageData(for: photoRef.id),
			let image = NSImage(data: imageData) {
			itemView.image = image
		}
		return itemView
	}
	
	// MARK: Private Methods
	
	// MARK: Public Properties
	
	// MARK: Private Properties
	
	private let dataSource: MarsPhotosDataSource
	
	// MARK: Outlets

}
