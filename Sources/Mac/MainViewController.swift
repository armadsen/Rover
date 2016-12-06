//
//  MainViewController.swift
//  Rover
//
//  Created by Andrew Madsen on 12/5/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, NSPageControllerDelegate, CollectionViewControllerDelegate {
	
	// MARK: Overridden
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		collectionViewController = storyboard?.instantiateController(withIdentifier: "CollectionViewController") as? CollectionViewController
		detailViewController = storyboard?.instantiateController(withIdentifier: "PhotoDetailViewController") as? PhotoDetailViewController
		
		pageController.delegate = self
		pageController.transitionStyle = .stackHistory
		pageController.arrangedObjects = [collectionViewController.dataSource]
		currentViewController = collectionViewController
		backButton.isEnabled = false
	}
		
	// MARK: Public Methods
	
	// MARK: CollectionViewControllerDelegate
	
	func photo(_ photo: MarsPhotoReference, selectedIn collectionViewController: CollectionViewController) {
		NSAnimationContext.runAnimationGroup({ (context) in
			self.pageController.arrangedObjects = [collectionViewController.dataSource, photo]
			self.pageController.animator().selectedIndex = 1
		}, completionHandler: {
			self.pageControllerDidEndLiveTransition(self.pageController)
		})
	}
	
	// MARK: Actions
	
	// MARK: NSPageControllerDelegate
	
	enum PageIdentifier: String {
		case collectionView
		case detailView
	}
	
	func pageController(_ pageController: NSPageController, identifierFor object: Any) -> String {
		if object is MarsPhotosDataSource {
			return PageIdentifier.collectionView.rawValue
		} else {
			return PageIdentifier.detailView.rawValue
		}
	}
	
	func pageController(_ pageController: NSPageController, viewControllerForIdentifier identifier: String) -> NSViewController {
		guard let identifier = PageIdentifier(rawValue: identifier) else { return NSViewController() }
		switch identifier {
		case .collectionView:
			return collectionViewController
		default:
			return detailViewController
		}
	}
	
	func pageController(_ pageC: NSPageController, prepare viewController: NSViewController, with object: Any?) {
		/*if let dataSource = object as? MarsPhotosDataSource,
			let collectionVC = viewController as? CollectionViewController {
			
		} else */ if let photoRef = object as? MarsPhotoReference,
			let detailVC = viewController as? PhotoDetailViewController {
			detailVC.photoInfo = photoRef
			if let imageData = PhotoCache.sharedCache.imageData(for: photoRef.id) {
				detailVC.image = NSImage(data: imageData)
			} else {
				detailVC.image = nil
			}
		}
		
		if let pagePresentable = viewController as? PagePresentable {
			pagePresentable.pageController = pageC
		}
	}
	
	func pageControllerDidEndLiveTransition(_ pageController: NSPageController) {
		pageController.completeTransition()
		
		if pageController.selectedIndex == 0 {
			backButton.isEnabled = false
			detailViewController.photoInfo = nil
			detailViewController.image = nil
		} else {
			backButton.isEnabled = true
		}

		currentViewController = pageController.selectedViewController
		self.view.window?.makeFirstResponder(self)
	}
	
	// MARK: Private Methods
	
	// MARK: Public Properties
	
	private var touchBarObserver: Observe?
	dynamic private(set) var currentViewController: NSViewController? {
		willSet {
			touchBarObserver = nil
			self.touchBar = nil
		}
		didSet {
			if let vc = currentViewController {
				touchBarObserver = Observe(vc, keyPath: "touchBar", options: [.initial]) { (touchBar) in
					self.touchBar = touchBar as? NSTouchBar
				}
			}
		}
	}
	
	// MARK: Private Properties
	
	var collectionViewController: CollectionViewController! {
		willSet {
			collectionViewController?.delegate = nil
		}
		didSet {
			collectionViewController?.delegate = self
		}
	}
	var detailViewController: PhotoDetailViewController!
	
	// MARK: Outlets
	
	@IBOutlet var backButton: NSButton!
	@IBOutlet var pageController: NSPageController!
}
