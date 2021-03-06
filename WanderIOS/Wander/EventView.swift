//
//  EventView.swift
//  Wander
//
//  Created by Shahbaz on 2019-09-14.
//  Copyright © 2019 Shahbaz Momi. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class EventView: UICornerRadiusView {
        
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var title: UILabel!
    @IBOutlet var subtitle: UILabel!
    
    @IBOutlet var goingCount: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        basicInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        basicInit()
    }
    
    func basicInit() {
        self.layer.cornerRadius = 4.0
        self.layer.masksToBounds = true
//        contentView = Bundle.main.loadNibNamed("EventView", owner: self, options: nil)![0] as! UIView
        Bundle.main.loadNibNamed("EventView", owner: self, options: nil)
        contentView.fixInView(self)
    }
    
    func consume(_ e : FBEvent) {
        title.text = e.name
        goingCount.text = String(e.attending_count)
        
        if(e.total_friends_going > 0) {
            DataManager.shared.makeMutualFriendsString(e.mutual_friends, subtitle)
        } else {
            subtitle.text = "No mutual friends"
        }
    }
    
    func consume(_ e : FBPlace) {
        title.text = e.place
        goingCount.text = String(e.friends.count)
        
        if(e.friends.count > 0) {
            DataManager.shared.makeMutualFriendsString(e.friends, subtitle)
        } else {
            subtitle.text = "No mutual friends"
        }
    }
    
}

extension UIView
{
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}

extension UIView {

    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
}
