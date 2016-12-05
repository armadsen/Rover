//
//  MainViewController.swift
//  Rover
//
//  Created by Andrew Madsen on 12/5/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Cocoa

protocol CollectionViewControllerDelegate: class {
	func photo(_ photo: MarsPhotoReference, selectedIn collectionViewController: CollectionViewController)
}

class CollectionViewController: NSViewController, CollectionViewDelegate {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		dataSource.collectionView = collectionView
		collectionView?.dataSource = dataSource
		dataSource.loadDataIfNeeded()
	}
	
	// MARK: CollectionViewDelegate
	
	func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
		for path in indexPaths {
			let photoRef = dataSource.photoReferences[path.item]
			delegate?.photo(photoRef, selectedIn: self)
		}
	}
	
	func collectionView(_ collectionView: CollectionView, didEndDisplaying cell: CollectionViewCell, forItemAt indexPath: IndexPath) {
		dataSource.cancelOperations(for: indexPath)
	}
	
	// Properties
	
	weak var delegate: CollectionViewControllerDelegate?
	
	let dataSource = MarsPhotosDataSource()
	
	@IBOutlet var collectionView: NSCollectionView!
}
