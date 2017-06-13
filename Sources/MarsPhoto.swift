//
//  MarsPhoto.swift
//  Rover
//
//  Created by Andrew Madsen on 11/1/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation

struct MarsPhotoReference {
    let id: Int
    let sol: Int
    let cameraName: String
    let earthDate: Date
    
    let imageURL: URL
}

extension MarsPhotoReference {
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    init?(dictionary: [String : Any]) {
        guard let id = dictionary["id"] as? Int,
            let sol = dictionary["sol"] as? Int,
            let cameraDict = dictionary["camera"] as? [String : Any],
            let cameraName = cameraDict["name"] as? String,
            let earthDateString = dictionary["earth_date"] as? String,
            let imageURLString = dictionary["img_src"] as? String else {
                return nil
        }
     
        let formatter = MarsPhotoReference.dateFormatter
        guard let earthDate = formatter.date(from: earthDateString),
            let imageURL = URL(string: imageURLString) else {
                return nil;
        }
		
		// Change image URL scheme to https
		var urlComps = URLComponents(url: imageURL, resolvingAgainstBaseURL: true)!
		urlComps.scheme = "https"
		
        self.init(id: id, sol: sol, cameraName: cameraName, earthDate: earthDate, imageURL: urlComps.url!)
    }
    
}
