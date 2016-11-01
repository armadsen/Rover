//
//  SolDescription.swift
//  Rover
//
//  Created by Andrew Madsen on 11/1/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation

struct SolDescription {
    let sol: Int
    let numberOfPhotos: Int
    let cameras: [String]
}

extension SolDescription {
    init?(dictionary: [String: Any]) {
        guard let sol = dictionary["sol"] as? Int,
            let numberOfPhotos = dictionary["total_photos"] as? Int,
            let cameraAbbreviations = dictionary["cameras"] as? [String] else {
                return nil
        }
        
        self.init(sol: sol, numberOfPhotos: numberOfPhotos, cameras: cameraAbbreviations)
    }
}
