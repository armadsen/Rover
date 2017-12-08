//
//  PhotoDetailViewController.swift
//  Rover
//
//  Created by Andrew Madsen on 12/5/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Cocoa

fileprivate extension NSTouchBar.CustomizationIdentifier {
	static let detailViewTouchBar = NSTouchBar.CustomizationIdentifier("com.devmountain.rover.detailViewTouchBar")
}

fileprivate extension NSTouchBarItem.Identifier {
	static let backButton = NSTouchBarItem.Identifier("com.rover.TouchBarItem.BackButton")
	static let upButton = NSTouchBarItem.Identifier("com.rover.TouchBarItem.UpButton")
	static let downButton = NSTouchBarItem.Identifier("com.rover.TouchBarItem.DownButton")
	static let upDownGroup = NSTouchBarItem.Identifier("com.rover.TouchBarItem.UpDownGroup")
	static let sharingService = NSTouchBarItem.Identifier("com.rover.TouchBarItem.SharingService")
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
		touchBar.defaultItemIdentifiers = [.backButton, NSTouchBarItem.Identifier.flexibleSpace, .upDownGroup, NSTouchBarItem.Identifier.otherItemsProxy]
		touchBar.customizationAllowedItemIdentifiers = [.backButton, NSTouchBarItem.Identifier.flexibleSpace, .upDownGroup, .sharingService, NSTouchBarItem.Identifier.otherItemsProxy, NSTouchBarItem.Identifier.flexibleSpace]
		return touchBar
	}
	
	// MARK: Public Methods
	
	// MARK: Actions
	
	@IBAction func goBack(_ sender: Any) {
		pageController?.navigateBack(sender)
	}
	
	@IBAction func goUp(_ sender: Any) {
		guard let index = photoIndex, index > 0 else { return }
		photoInfo = photosProvider.photoReferences[index-1]
	}
	
	@IBAction func goDown(_ sender: Any) {
		let photoRefs = photosProvider.photoReferences
		guard let index = photoIndex, index+1 < photoRefs.count else { return }
		photoInfo = photoRefs[index+1]
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
	
	private func fetchNewPhoto() {
		guard let photoRef = photoInfo else { return }

		photosProvider.image(for: photoRef) { image in
			guard photoRef == self.photoInfo else { return }
			self.image = image
		}
	}
	
	// MARK: Public Properties
	
	var photosProvider = PhotosProvider.sharedProvider
	
	var photoInfo: MarsPhotoReference? {
		didSet {
			image = nil
			updateViews()
			fetchNewPhoto()
		}
	}
	
	var photoIndex: Int? {
		guard let photoRef = photoInfo else { return nil }
		return photosProvider.photoReferences.index(of: photoRef)
	}
	
	weak var pageController: NSPageController?
	
	// MARK: Private Properties
	
	fileprivate var image: Image? {
		didSet {
			updateViews()
		}
	}
	
	// MARK: Outlets
	@IBOutlet var imageView: NSImageView!
	@IBOutlet var idLabel: NSTextField!
	@IBOutlet var solLabel: NSTextField!
	@IBOutlet var cameraLabel: NSTextField!
	@IBOutlet var earthDateLabel: NSTextField!
	
}

extension PhotoDetailViewController: NSTouchBarDelegate {
	func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
		let item: NSTouchBarItem
		
		switch identifier {
		case NSTouchBarItem.Identifier.backButton:
			let buttonItem = NSCustomTouchBarItem(identifier: identifier)
			buttonItem.customizationLabel = "Back"
			let image = NSImage(named: NSImage.Name.touchBarGoBackTemplate)!
			buttonItem.view = NSButton(image: image, target: self, action: #selector(goBack(_:)))
			item = buttonItem
		case NSTouchBarItem.Identifier.upDownGroup:
			let upItem = self.touchBar(touchBar, makeItemForIdentifier: .upButton)!
			let downItem = self.touchBar(touchBar, makeItemForIdentifier: .downButton)!
			let groupItem = NSGroupTouchBarItem(identifier: .upDownGroup, items: [downItem, upItem])
			groupItem.customizationLabel = "Navigation"
			item = groupItem
		case NSTouchBarItem.Identifier.upButton:
			let buttonItem = NSCustomTouchBarItem(identifier: identifier)
			buttonItem.customizationLabel = "Up"
			let image = NSImage(named: NSImage.Name.touchBarGoUpTemplate)!
			buttonItem.view = NSButton(image: image, target: self, action: #selector(goUp(_:)))
			item = buttonItem
		case NSTouchBarItem.Identifier.downButton:
			let buttonItem = NSCustomTouchBarItem(identifier: identifier)
			buttonItem.customizationLabel = "Down"
			let image = NSImage(named: NSImage.Name.touchBarGoDownTemplate)!
			buttonItem.view = NSButton(image: image, target: self, action: #selector(goDown(_:)))
			item = buttonItem
		case NSTouchBarItem.Identifier.sharingService:
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
    guard let image = image else { return [] }
		return [image]
	}
}
