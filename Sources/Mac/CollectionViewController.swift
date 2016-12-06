//
//  MainViewController.swift
//  Rover
//
//  Created by Andrew Madsen on 12/5/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Cocoa

fileprivate extension NSTouchBarCustomizationIdentifier {
	static let collectionViewTouchBar = NSTouchBarCustomizationIdentifier("com.devmountain.rover.collectionViewTouchBar")
}

fileprivate extension NSTouchBarItemIdentifier {
	static let scrubber = NSTouchBarItemIdentifier("com.rover.TouchBarItem.CollectionViewScrubber")
}

protocol CollectionViewControllerDelegate: class {
	func photo(_ photo: MarsPhotoReference, selectedIn collectionViewController: CollectionViewController)
}

class CollectionViewController: NSViewController, CollectionViewDelegate, PagePresentable {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		dataSource.collectionView = collectionView
		collectionView?.dataSource = dataSource
		
		let nc = NotificationCenter.default
		nc.addObserver(self, selector: #selector(dataLoaded(_:)), name: MarsPhotosDataSource.DataLoadedNotification, object: dataSource)
	}
	
	override func makeTouchBar() -> NSTouchBar? {
		let touchBar = NSTouchBar()
		touchBar.delegate = self
		touchBar.customizationIdentifier = .collectionViewTouchBar
		touchBar.defaultItemIdentifiers = [.scrubber, .otherItemsProxy]
		touchBar.customizationAllowedItemIdentifiers = [.scrubber, .otherItemsProxy]
		
		return touchBar
	}
	
	// MARK: CollectionViewDelegate
	
	func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
		for path in indexPaths {
			let photoRef = dataSource.photoReferences[path.item]
			delegate?.photo(photoRef, selectedIn: self)
		}
	}
	
	func collectionView(_ collectionView: CollectionView, didEndDisplaying cell: CollectionViewCell, forItemAt indexPath: IndexPath) {
		dataSource.cancelLoading(for: indexPath)
	}
	
	// Notifications
	
	func dataLoaded(_ notification: NSNotification) {
		self.invalidateTouchBar()
	}
	
	// Properties
	
	weak var delegate: CollectionViewControllerDelegate?
	
	let dataSource = MarsPhotosDataSource()
	
	weak var pageController: NSPageController?
	
	@IBOutlet var collectionView: NSCollectionView!
}

extension CollectionViewController: NSTouchBarDelegate {
	func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItemIdentifier) -> NSTouchBarItem? {
		let item: NSTouchBarItem
		
		switch identifier {
		case NSTouchBarItemIdentifier.scrubber:
			let scrubberItem = PhotoScrubberBarItem(identifier: identifier)
			scrubberItem.customizationLabel = "Photo Scrubber"
			scrubberItem.scrubber?.delegate = self
			item = scrubberItem
		default:
			return nil
		}
		
		return item
	}
}

extension CollectionViewController: NSScrubberDelegate {
	func scrubber(_ scrubber: NSScrubber, didSelectItemAt selectedIndex: Int) {
		let photoRef = dataSource.photoReferences[selectedIndex]
		delegate?.photo(photoRef, selectedIn: self)
	}
}
