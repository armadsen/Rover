//
//  FetchImageOperation.swift
//  Rover
//
//  Created by Andrew Madsen on 11/1/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit

class FetchPhotoOperation: ConcurrentOperation {
    
    init(photoReference: MarsPhotoReference, session: URLSession = URLSession.shared) {
        self.photoReference = photoReference
        self.session = session
        super.init()
    }
 
    override func start() {
        state = .isExecuting
        var urlComps = URLComponents(url: photoReference.imageURL, resolvingAgainstBaseURL: true)!
        urlComps.scheme = "https"
        let url = urlComps.url!
        
        let task = session.dataTask(with: url) { (data, response, error) in
            defer { self.state = .isFinished }
            if let error = error {
                NSLog("Error fetching data for \(self.photoReference): \(error)")
                return
            }
            
            self.imageData = data
        }
        task.resume()
        dataTask = task
    }
    
    override func cancel() {
        dataTask?.cancel()
        super.cancel()
    }
    
    // MARK: Properties
    
    let photoReference: MarsPhotoReference
    
    private let session: URLSession

    private(set) var imageData: Data?
    
    private var dataTask: URLSessionDataTask?
}
