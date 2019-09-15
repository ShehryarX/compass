//
//  DataManager.swift
//  Wander
//
//  Created by Shahbaz on 2019-09-14.
//  Copyright © 2019 Shahbaz Momi. All rights reserved.
//

import FBSDKCoreKit
import Foundation
import CoreLocation
import FirebaseDatabase

class DataManager {
    
    public static let shared = DataManager()
    
    private static let endpoint = "https://us-central1-wandar-85910.cloudfunctions.net/wandAR"
    
    private var ref: DatabaseReference?
    
    
    private init() {}
    
    var realtimeEvents = [FBEvent]()
    var names = [String : String]()
        
    func prefetch() {
        if ref == nil {
            ref = Database.database()
                .reference()
            ref!.keepSynced(true)
        }
        
        var res = [String : String]()
        
        ref!.child("users").observeSingleEvent(of: .value, with: {snapshot in
            for case let rest as DataSnapshot in snapshot.children {
                guard let r = rest.value as? NSDictionary else { continue }
                let name = r["display"] as? String
                let id = r["id"] as? String
                
                if(id == nil || name == nil) {
                    continue
                }

                res[id!] = name!
            }
            self.names = res
        })
        
    }
    
    func makeMutualFriendsString(_ idsArr : [String], _ lbl: UILabel) {
        let ids = idsArr.shuffled()
        if(ids.count == 1) {
            // default until loaded
            lbl.text = names[ids[0]] ?? "1 mutual friend" + " is going"
        } else if(ids.count == 2) {
            let a = names[ids[0]]
            let b = names[ids[1]]
            if a != nil && b != nil {
                lbl.text = a! + " and " + b! + " are going"
            } else {
                lbl.text = "2 mutual friends"
            }
        } else {
            let a = names[ids[0]]
            let b = names[ids[1]]
            if a != nil && b != nil {
                lbl.text = a! + ", " + b! + ", and " + String(ids.count - 2) + " friends are going"
            } else {
                lbl.text = String(ids.count) + " mutual friends"
            }
        }
    }
    
    func makeDateString(_ e : FBEvent) -> String {
                
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let st = formatter.date(from: e.start_time)
        let en = formatter.date(from: e.end_time)
        
        if(st == nil || en == nil) {
            return e.start_time + " - " + e.end_time
        }
        
        let outFormatter = DateFormatter()
        outFormatter.dateFormat = "EEEE, MMM dd"
    
        if(e.start_time == e.end_time) {
            return outFormatter.string(from: st!)
        }
        
        return outFormatter.string(from: st!) + " - " + outFormatter.string(from: en!)
    }
    
    func doGet(_ token: AccessToken, _ loc: CLLocation, _ completion: (([FBEvent]?) -> Void)? = nil) {
        var url = URLComponents(string: DataManager.endpoint)
        url?.queryItems = [
            URLQueryItem(name: "user_id", value: token.userID),
            URLQueryItem(name: "access_token", value: token.tokenString),
            URLQueryItem(name: "lat", value: String(loc.coordinate.latitude)),
            URLQueryItem(name: "lon", value: String(loc.coordinate.longitude))
        ]
    
        let req = URLRequest(url: url!.url!)
        
        print(url!.url!.description)
        
        URLSession.shared.dataTask(with: req, completionHandler: {d, response, err in
            guard let data = d,                            // is there data
                let response = response as? HTTPURLResponse,
                response.statusCode == 200
            else {
                return
            }
                
            do {
                let objs = try JSONDecoder().decode([FBEvent].self, from: data)
                self.realtimeEvents = objs
                DispatchQueue.main.async {
                    completion?(objs)
                }
            } catch {
                print(error)
            }
        }).resume()
    }
}


struct FBLoc: Codable {
    let street: String
    let lat: Double
    let long: Double
}

struct FBEvent: Codable {
    let id: String
    let name: String
    let description: String
    
    let attending_count: Int
    let cover_image: String
    
    let start_time: String
    let end_time: String
    
    let happening_now: Bool
    
    let total_friends_going: Int
    
    let mutual_friends: [String]
    
    let venue_name: String
    
    let location: FBLoc
    
}
