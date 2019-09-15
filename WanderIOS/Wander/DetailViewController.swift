//
//  DetailViewController.swift
//  Wander
//
//  Created by Shahbaz on 2019-09-14.
//  Copyright © 2019 Shahbaz Momi. All rights reserved.
//

import Foundation
import UIKit

class DetailViewController: UIViewController {
   
    @IBOutlet var titleView: UILabel!
    @IBOutlet var descView: UITextView!
    
    @IBOutlet var mutual: UILabel!
    @IBOutlet var total: UILabel!
    
    @IBOutlet var distance: UILabel!
    @IBOutlet var hours: UILabel!
    
    @IBOutlet var imageView: UIImageView!
    
    var event: FBEvent? = nil
    
    override func viewDidLoad() {
        guard let e = event else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        titleView.text = e.name
        descView.text = e.description
        total.text = String(e.attending_count) + " total going"
        distance.text = e.venue_name + "\n" + e.location.street
        
        if(e.total_friends_going > 0) {
            DataManager.shared.makeMutualFriendsString(e.mutual_friends, mutual)
        } else {
            mutual.text = "No mutual friends"
        }
        
        hours.text = DataManager.shared.makeDateString(e)

        if let url = URL(string: e.cover_image) {
            DispatchQueue.global(qos: .userInitiated).async {
                let imageData = NSData(contentsOf: url)
                DispatchQueue.main.async {
                    if imageData != nil {
                        let image = UIImage(data: imageData! as Data)
                        self.imageView.image = image
                        self.imageView.sizeToFit()
                    }
                }
            }
        }
    }
    
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
