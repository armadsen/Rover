//
//  MarsRoverClient.swift
//  Rover
//
//  Created by Andrew Madsen on 11/1/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation

class MarsRoverClient {
    func fetchMarsRover(named name: String,
                        using session: URLSession = URLSession.shared,
                        completion: @escaping (MarsRover?, Error?) -> Void) {
        
        let url = self.url(forInfoForRover: name)
        
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "com.DevMountain.Rover.ErrorDomain", code: -1, userInfo: nil))
                return
            }
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                guard let dictionary = jsonObject as? [String : Any],
                    let manifest = dictionary["photo_manifest"] as? [String : Any] else {
                        throw NSError(domain: "com.DevMountain.Rover.ErrorDomain", code: -1, userInfo: nil)
                }
                
                let rover = MarsRover(dictionary: manifest)
                completion(rover, nil)
            } catch {
                completion(nil, error)
            }
        }
        dataTask.resume()
    }
    
    func fetchPhotos(from rover: MarsRover, onSol sol: Int,
                     using session: URLSession = URLSession.shared,
                     completion: @escaping ([MarsPhotoReference]?, Error?) -> Void) {
        
        let url = self.url(forPhotosfromRover: rover.name, on: sol)
        
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "com.DevMountain.Rover.ErrorDomain", code: -1, userInfo: nil))
                return
            }
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                guard let dictionary = jsonObject as? [String : Any],
                    let photoDictionaries = dictionary["photos"] as? [[String : Any]] else {
                        throw NSError(domain: "com.DevMountain.Rover.ErrorDomain", code: -1, userInfo: nil)
                }
                
                let photos = photoDictionaries.flatMap { MarsPhotoReference(dictionary: $0) }
                completion(photos, nil)
            } catch {
                completion(nil, error)
            }
        }
        dataTask.resume()
    }
    
    private let baseURL = URL(string: "https://api.nasa.gov/mars-photos/api/v1")!
    private let apiKey = "qzGsj0zsKk6CA9JZP1UjAbpQHabBfaPg2M5dGMB7"
    
    private func url(forInfoForRover roverName: String) -> URL {
        var url = baseURL
        url.appendPathComponent("manifests")
        url.appendPathComponent(roverName)
        let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
        return urlComponents.url!
    }
    
    private func url(forPhotosfromRover roverName: String, on sol: Int) -> URL {
        var url = baseURL
        url.appendPathComponent("rovers")
        url.appendPathComponent(roverName)
        url.appendPathComponent("photos")
        let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = [URLQueryItem(name: "sol", value: String(sol)),
                                    URLQueryItem(name: "api_key", value: apiKey)]
        return urlComponents.url!
    }
}
