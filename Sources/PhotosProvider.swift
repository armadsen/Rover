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
	
	init(client: MarsRoverClient = MarsRoverClient()) {
		self.client = client
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
		
		var urlComps = URLComponents(url: photoReference.imageURL, resolvingAgainstBaseURL: true)!
		urlComps.scheme = "https"
		let url = urlComps.url!
		
		let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
			if let error = error {
				NSLog("Error fetching data for \(photoReference): \(error)")
				completion(nil)
				return
			}
			guard let data = data else {
				NSLog("Error fetching data for \(photoReference)")
				completion(nil)
				return
			}
			completion(Image(data: data))
		}
		task.resume()
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
