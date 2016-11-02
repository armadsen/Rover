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
        return photoReferences.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCollectionViewCell ?? ImageCollectionViewCell()
        
        let photoRef = photoReferences[indexPath.row]
        if let imageData = cache.imageData(for: photoRef.id),
            let image = UIImage(data: imageData) {
            cell.imageView.image = image
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
                
                if let currentIndexPath = collectionView.indexPath(for: cell),
                    currentIndexPath != indexPath {
                    print("Got image for now-reused cell")
                    return // Cell has been reused
                }
                
                if let data = fetchOp.imageData,
                    let image = UIImage(data: data) {
                    cell.imageView.image = image
                }
            }
            
            cacheOp.addDependency(fetchOp)
            uiUpdateOp.addDependency(fetchOp)
            
            photoFetchQueue.addOperation(fetchOp)
            photoFetchQueue.addOperation(cacheOp)
            OperationQueue.main.addOperation(uiUpdateOp)
            
            operations[photoRef.id] = fetchOp
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photoRef = photoReferences[indexPath.row]
        operations[photoRef.id]?.cancel()
    }
    
    // Properties
    
    private let client = MarsRoverClient()
    private let cache = PhotoCache()
    private let photoFetchQueue = OperationQueue()
    private var operations = [Int : Operation]()
    
    private var roverInfo: MarsRover? {
        didSet {
            solDescription = roverInfo?.solDescriptions.last
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
