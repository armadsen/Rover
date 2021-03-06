//
//  PhotoCache.swift
//  Rover
//
//  Created by Andrew Madsen on 11/1/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation

class PhotoCache {
	
	static let sharedCache = PhotoCache()
    
    func cache(imageData: Data, for id: Int) {
        cacheQueue.async {
            self.cache[id] = imageData
        }
    }
    
    func imageData(for id: Int) -> Data? {
        var result: Data?
        cacheQueue.sync {
            result = cache[id]
        }
        return result
    }
    
    private var cache = [Int : Data]()
    private let cacheQueue = DispatchQueue(label: "com.DevMountain.Rover.ImageCacheQueue")
}
