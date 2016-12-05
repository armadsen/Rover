//
//  MarsPhotoDataSource.swift
//  Rover
//
//  Created by Andrew Madsen on 12/5/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation

class MarsPhotosDataSource: NSObject, CollectionViewDataSource {
	
	init(client: MarsRoverClient = MarsRoverClient(), cache: PhotoCache = PhotoCache.sharedCache) {
		self.client = client
		self.cache = cache
	}
	
	// MARK: Overridden
	
	// MARK: Public Methods
	
	private var hasLoadedData = false
	func loadDataIfNeeded() {
		guard !hasLoadedData else { return }
		
		client.fetchMarsRover(named: "curiosity") { (rover, error) in
			if let error = error {
				NSLog("Error fetching info for curiosity: \(error)")
				return
			}
			
			self.roverInfo = rover
			self.hasLoadedData = true
		}
	}
	
	func cancelOperations(for indexPath: IndexPath) {
		let photoRef = photoReferences[indexPath.item]
		operations[photoRef.id]?.cancel()
	}
	
	// MARK: CollectionViewDataSource
	
	func numberOfSections(in collectionView: CollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: CollectionView, numberOfItemsInSection section: Int) -> Int {
		return photoReferences.count
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
		let photoRef = photoReferences[indexPath.item]
		if let imageData = cache.imageData(for: photoRef.id),
			let image = Image(data: imageData) {
			cell.imageView?.image = image
		} else {
			// Start an operation to fetch image data
			let fetchOp = FetchPhotoOperation(photoReference: photoRef)
			let cacheOp = BlockOperation {
				if let data = fetchOp.imageData {
					self.cache.cache(imageData: data, for: photoRef.id)
				}
			}
			let uiUpdateOp = BlockOperation {
				defer { self.operations.removeValue(forKey: photoRef.id) }
				
				if let currentIndexPath = self.collectionView?.indexPath(for: cell),
					currentIndexPath != indexPath {
					print("Got image for now-reused cell")
					return // Cell has been reused
				}
				
				if let data = fetchOp.imageData,
					let image = Image(data: data) {
					cell.imageView?.image = image
				}
			}
			
			cacheOp.addDependency(fetchOp)
			uiUpdateOp.addDependency(fetchOp)
			
			photoFetchQueue.addOperation(fetchOp)
			photoFetchQueue.addOperation(cacheOp)
			OperationQueue.main.addOperation(uiUpdateOp)
			
			operations[photoRef.id] = fetchOp
		}
	}
	
	// MARK: Public Properties
	
	private(set) var photoReferences = [MarsPhotoReference]() {
		didSet {
			DispatchQueue.main.async { self.collectionView?.reloadData() }
		}
	}

	
	// MARK: Private Properties
	
	var collectionView: CollectionView?
	private let client: MarsRoverClient
	private let cache: PhotoCache
	private let photoFetchQueue = OperationQueue()
	private var operations = [Int : Operation]()
	
	private var roverInfo: MarsRover? = nil {
		didSet {
			solDescription = roverInfo?.solDescriptions[10]
		}
	}
	private var solDescription: SolDescription? = nil {
		didSet {
			if let rover = roverInfo,
				let sol = solDescription?.sol {
				client.fetchPhotos(from: rover, onSol: sol) { (photoRefs, error) in
					if let e = error { NSLog("Error fetching photos for \(rover.name) on sol \(sol): \(e)"); return }
					self.photoReferences = photoRefs ?? []
				}
			}
		}
	}
	
	// MARK: Outlets
	
}
