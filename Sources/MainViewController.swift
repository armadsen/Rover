//
//  MainViewController.swift
//  Rover
//
//  Created by Andrew Madsen on 11/1/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		client.fetchMarsRover(named: "curiosity") { (rover, error) in
			if let error = error {
				NSLog("Error fetching info for curiosity: \(error)")
				return
			}
			
			self.roverInfo = rover
		}
	}
	
	// UICollectionViewDataSource/Delegate
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		NSLog("num photos: \(photoReferences.count)")
		return photoReferences.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCollectionViewCell ?? ImageCollectionViewCell()
		
		let photoRef = photoReferences[indexPath.row]
		if let imageData = cache.imageData(for: photoRef.id),
			let image = UIImage(data: imageData) {
			cell.imageView.image = image
		} else {
			
			NSLog("Fetch")
			let url = photoRef.imageURL
			let session = URLSession.shared
			let task = session.dataTask(with: url) { (data, response, error) in
				if let error = error {
					NSLog("Error fetching data for \(photoRef): \(error)")
					return
				}
				
				if let currentIndexPath = collectionView.indexPath(for: cell),
					currentIndexPath != indexPath {
					print("Got image for now-reused cell")
					return // Cell has been reused
				}
				
				guard let data = data,
					let image = UIImage(data: data) else { return }
				
				self.cache.cache(imageData: data, for: photoRef.id)
				cell.imageView.image = image
			}
			task.resume()
		}
		
		return cell
	}
	
	// Properties
	
	private let client = MarsRoverClient()
	private let cache = PhotoCache()
	
	private var roverInfo: MarsRover? {
		didSet {
			solDescription = roverInfo?.solDescriptions[32]
		}
	}
	private var solDescription: SolDescription? {
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
			DispatchQueue.main.async { self.collectionView?.reloadData() }
		}
	}
	
	@IBOutlet var collectionView: UICollectionView!
}
