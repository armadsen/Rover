//
//  PhotoCache.swift
//  Rover
//
//  Created by Andrew Madsen on 11/1/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit

class PhotoCache {
    
    func cache(imageData: Data, for id: Int) {
		self.cache[id] = imageData
    }
    
    func imageData(for id: Int) -> Data? {
		return cache[id]
    }
    
    private var cache = [Int : Data]()
}
