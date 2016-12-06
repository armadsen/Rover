//
//  PhotosProvider.swift
//  Rover
//
//  Created by Andrew Madsen on 12/5/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation

class PhotosProvider {
	static let DataLoadedNotification = NSNotification.Name("PhotosProviderDataDidChange")
	
	static let sharedProvider = PhotosProvider()
	
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
	
	func image(for photoReference: MarsPhotoReference, completion: @escaping (Image?) -> Void) {
		if let cachedImageData = cache.imageData(for: photoReference.id),
			let image = Image(data: cachedImageData) {
			completion(image)
			return
		}
		
		// Start an operation to fetch image data
		let fetchOp = FetchPhotoOperation(photoReference: photoReference)
		let cacheOp = BlockOperation {
			if let data = fetchOp.imageData {
				self.cache.cache(imageData: data, for: photoReference.id)
			}
		}
		let completionOp = BlockOperation {
			defer { self.operations.removeValue(forKey: photoReference.id) }

			if let data = fetchOp.imageData,
				let image = Image(data: data) {
				completion(image)
			} else {
				completion(nil)
			}
		}
		
		cacheOp.addDependency(fetchOp)
		completionOp.addDependency(fetchOp)
		
		photoFetchQueue.addOperation(fetchOp)
		photoFetchQueue.addOperation(cacheOp)
		OperationQueue.main.addOperation(completionOp)
		
		operations[photoReference.id] = fetchOp
	}
	
	func cancelOperations(for photoReference: MarsPhotoReference) {
		operations[photoReference.id]?.cancel()
	}
	
	// MARK: Actions
	
	// MARK: Private Methods
	
	// MARK: Public Properties
	
	private(set) var photoReferences = [MarsPhotoReference]() {
		didSet {
			DispatchQueue.main.async {
				let nc = NotificationCenter.default
				nc.post(name: PhotosProvider.DataLoadedNotification, object: self)
			}
		}
	}
	
	// MARK: Private Properties
	
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
