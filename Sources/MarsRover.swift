//
//  MarsRover.swift
//  Rover
//
//  Created by Andrew Madsen on 11/1/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation

struct MarsRover {
    let name: String
    
    let launchDate: Date
    let landingDate: Date
    
    enum Status: String {
        case active, complete
    }
    let status: Status
    
    let maxSol: Int
    let maxDate: Date
    
    let numberOfPhotos: Int
    
    let solDescriptions: [SolDescription]
}

extension MarsRover {
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    init?(dictionary: [String: Any]) {
        guard let name = dictionary["name"] as? String,
            let launchDateString = dictionary["launch_date"] as? String,
            let landingDateString = dictionary["landing_date"] as? String,
            let statusString = dictionary["status"] as? String,
            let status = Status(rawValue: statusString),
            let maxSol = dictionary["max_sol"] as? Int,
            let maxDateString = dictionary["max_date"] as? String,
            let numberOfPhotos = dictionary["total_photos"] as? Int,
            let solDescriptionDictionaries = dictionary["photos"] as? [[String : Any]] else {
                return nil
        }
        
        let formatter = MarsRover.dateFormatter
        guard let launchDate = formatter.date(from: launchDateString),
            let landingDate = formatter.date(from: landingDateString),
            let maxDate = formatter.date(from: maxDateString) else {
                return nil
        }

        let solDescriptions = solDescriptionDictionaries.flatMap { SolDescription(dictionary: $0) }
        
        self.init(name: name,
                  launchDate: launchDate,
                  landingDate: landingDate,
                  status: status,
                  maxSol: maxSol,
                  maxDate: maxDate,
                  numberOfPhotos: numberOfPhotos,
                  solDescriptions: solDescriptions)
    }
}
