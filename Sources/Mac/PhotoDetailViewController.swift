//
//  PhotoDetailViewController.swift
//  Rover
//
//  Created by Andrew Madsen on 12/5/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Cocoa

class PhotoDetailViewController: NSViewController {

	// MARK: Overridden
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		updateViews()
	}
	
	// MARK: Public Methods
	
	// MARK: Actions
	
	// MARK: Private Methods
	
	private func updateViews() {
		guard isViewLoaded else { return }
		imageView.image = image
		idLabel.objectValue = photoInfo?.id
		solLabel.objectValue = photoInfo?.sol
		cameraLabel.stringValue = photoInfo?.cameraName ?? ""
		earthDateLabel.objectValue = photoInfo?.earthDate
	}
	
	// MARK: Public Properties
	
	var photoInfo: MarsPhotoReference? {
		didSet {
			updateViews()
		}
	}
	
	var image: Image? {
		didSet {
			updateViews()
		}
	}
	
	// MARK: Private Properties
	
	// MARK: Outlets
	@IBOutlet var imageView: NSImageView!
	@IBOutlet var idLabel: NSTextField!
	@IBOutlet var solLabel: NSTextField!
	@IBOutlet var cameraLabel: NSTextField!
	@IBOutlet var earthDateLabel: NSTextField!
	
}
