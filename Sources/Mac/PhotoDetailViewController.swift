//
//  PhotoDetailViewController.swift
//  Rover
//
//  Created by Andrew Madsen on 12/5/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Cocoa

fileprivate extension NSTouchBarCustomizationIdentifier {
	static let detailViewTouchBar = NSTouchBarCustomizationIdentifier("com.devmountain.rover.detailViewTouchBar")
}

fileprivate extension NSTouchBarItemIdentifier {
	static let backButton = NSTouchBarItemIdentifier("com.rover.TouchBarItem.BackButton")
	static let sharingService = NSTouchBarItemIdentifier("com.rover.TouchBarItem.SharingService")
}


class PhotoDetailViewController: NSViewController, PagePresentable {

	// MARK: Overridden
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		updateViews()
	}
	
	override func makeTouchBar() -> NSTouchBar? {
		let touchBar = NSTouchBar()
		touchBar.delegate = self
		touchBar.customizationIdentifier = .detailViewTouchBar
		touchBar.defaultItemIdentifiers = [.backButton, .sharingService, .otherItemsProxy]
		touchBar.customizationAllowedItemIdentifiers = [.backButton, .sharingService, .otherItemsProxy]
		return touchBar
	}
	
	// MARK: Public Methods
	
	// MARK: Actions
	
	@IBAction func goBack(_ sender: Any) {
		pageController?.navigateBack(sender)
	}
	
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
	
	weak var pageController: NSPageController?
	
	// MARK: Private Properties
	
	// MARK: Outlets
	@IBOutlet var imageView: NSImageView!
	@IBOutlet var idLabel: NSTextField!
	@IBOutlet var solLabel: NSTextField!
	@IBOutlet var cameraLabel: NSTextField!
	@IBOutlet var earthDateLabel: NSTextField!
	
}

extension PhotoDetailViewController: NSTouchBarDelegate {
	func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItemIdentifier) -> NSTouchBarItem? {
		let item: NSTouchBarItem
		
		switch identifier {
		case NSTouchBarItemIdentifier.backButton:
			let buttonItem = NSCustomTouchBarItem(identifier: identifier)
			let backImage = NSImage(named: NSImageNameTouchBarGoBackTemplate)!
			buttonItem.view = NSButton(image: backImage, target: self, action: #selector(goBack(_:)))
			item = buttonItem
		case NSTouchBarItemIdentifier.sharingService:
			let sharingItem = NSSharingServicePickerTouchBarItem(identifier: identifier)
			sharingItem.delegate = self
			item = sharingItem
		default:
			return nil
		}
		
		return item
	}
}

extension PhotoDetailViewController: NSSharingServicePickerTouchBarItemDelegate {
	func items(for pickerTouchBarItem: NSSharingServicePickerTouchBarItem) -> [Any] {
		return []
	}
}
