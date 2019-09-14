//
//  DataManager.swift
//  Wander
//
//  Created by Nigga on 2019-09-14.
//  Copyright © 2019 Shahbaz Momi. All rights reserved.
//

import FBSDKCoreKit
import Foundation
import CoreLocation

class DataManager {
    
    public static let shared = DataManager()
    
    private static let endpoint = "https://us-central1-wandar-85910.cloudfunctions.net/wandAR"
    
    private init() {
        
    }
    
    func doGet(_ token: AccessToken, _ loc: CLLocation, _ completion: (() -> Void)? = nil) {
        var url = URLComponents(string: DataManager.endpoint)
        url?.queryItems = [
            URLQueryItem(name: "user_id", value: token.userID),
            URLQueryItem(name: "access_token", value: token.tokenString),
            URLQueryItem(name: "lat", value: String(loc.coordinate.latitude)),
            URLQueryItem(name: "lon", value: String(loc.coordinate.longitude))
        ]
    
        let req = URLRequest(url: url!.url!)
        
        
        URLSession.shared.dataTask(with: req, completionHandler: {d, response, err in
                guard let data = d,                            // is there data
                    let response = response as? HTTPURLResponse
                else {
                    return
                }
            
                print(response.statusCode)
            
                let str = String(bytes: data, encoding: .utf8)
                print(str)
            }).resume()
    }
}

struct FBEvent {
    
    let id: String
    let title: String
    let subtitle: String
    
    let hours: String
    
    let totalGoing: String
    let friendsGoing: String
    
}
