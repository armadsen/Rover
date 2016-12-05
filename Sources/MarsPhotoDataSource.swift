//
//  MarsPhotoDataSource.swift
//  Rover
//
//  Created by Andrew Madsen on 12/5/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation

class MarsPhotoDataSource: NSObject, CollectionViewDataSource, CollectionViewDelegate {
	
	init(collectionView: CollectionView, client: MarsRoverClient = MarsRoverClient()) {
		self.collectionView = collectionView
		self.client = client
	}
	
	// MARK: Overridden
	
	// MARK: Public Methods
	
	func loadData() {
		client.fetchMarsRover(named: "curiosity") { (rover, error) in
			if let error = error {
				NSLog("Error fetching info for curiosity: \(error)")
				return
			}
			
			self.roverInfo = rover
		}
	}
	
	// MARK: CollectionViewDataSource/Delegate
	
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
	
	func collectionView(_ collectionView: CollectionView, didEndDisplaying cell: CollectionViewCell, forItemAt indexPath: IndexPath) {
		let photoRef = photoReferences[indexPath.item]
		operations[photoRef.id]?.cancel()
	}
	
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
				
				if let currentIndexPath = self.collectionView.indexPath(for: cell),
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
	
	// MARK: Private Properties
	
	private let collectionView: CollectionView
	private let client: MarsRoverClient
	private let cache = PhotoCache()
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
	private var photoReferences = [MarsPhotoReference]() {
		didSet {
			DispatchQueue.main.async { self.collectionView.reloadData() }
		}
	}
	
	// MARK: Outlets
	
}
