//
//  MarsPhotoDataSource.swift
//  Rover
//
//  Created by Andrew Madsen on 12/5/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation

class MarsPhotosDataSource: NSObject, CollectionViewDataSource {
	
	static let DataLoadedNotification = NSNotification.Name("MarsPhotosDataSourceDataLoaded")
	
	init(photosProvider: PhotosProvider = PhotosProvider.sharedProvider) {
		self.photosProvider = photosProvider
		
		super.init()
		
		let nc = NotificationCenter.default
		nc.addObserver(self, selector: #selector(dataDidLoad(_:)), name: PhotosProvider.DataLoadedNotification, object: photosProvider)
		photosProvider.loadDataIfNeeded()
	}
	
	// MARK: Overridden
	
	// MARK: Public Methods
	
	func cancelLoading(for indexPath: IndexPath) {
		let photoRef = photoReferences[indexPath.item]
		photosProvider.cancelOperations(for: photoRef)
	}
	
	// MARK: CollectionViewDataSource
	
	func numberOfSections(in collectionView: CollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: CollectionView, numberOfItemsInSection section: Int) -> Int {
		return photosProvider.photoReferences.count
	}

	#if os(iOS)
	func collectionView(_ collectionView: CollectionView, cellForItemAt indexPath: IndexPath) -> CollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCollectionViewCell ?? ImageCollectionViewCell()
		configure(cell: cell, forItemAt: indexPath)
		return cell
	}
	#else
	func collectionView(_ collectionView: CollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> CollectionViewCell {
		let cell = collectionView.makeItem(withIdentifier: "ImageCell", for: indexPath)
		configure(cell: cell, forItemAt: indexPath)
		return cell
	}
	#endif
		
	// MARK: Actions
	
	// MARK: Private Methods
	
	private func configure(cell: ImageCollectionViewCell, forItemAt indexPath: IndexPath) {
		let photoRef = photosProvider.photoReferences[indexPath.item]
		
		photosProvider.image(for: photoRef) { (image) in
			if let currentIndexPath = self.collectionView?.indexPath(for: cell),
				currentIndexPath != indexPath {
				print("Got image for now-reused cell")
				return // Cell has been reused
			}
			
			cell.imageView?.image = image
		}
	}
	
	// MARK: Notifications
	
	func dataDidLoad(_ notification: NSNotification) {
		collectionView?.reloadData()
		
		let nc = NotificationCenter.default
		nc.post(name: MarsPhotosDataSource.DataLoadedNotification, object: self)
	}
	
	// MARK: Public Properties
	
	var photoReferences: [MarsPhotoReference] { return photosProvider.photoReferences }
	
	// MARK: Private Properties
	
	var collectionView: CollectionView?
	let photosProvider: PhotosProvider
	
	// MARK: Outlets
	
}
