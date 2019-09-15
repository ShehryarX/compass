//
//  UICornerRadiusView.swift
//  Wander
//
//  Created by Shahbaz on 2019-09-14.
//  Copyright © 2019 Shahbaz Momi. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class UICornerRadiusView: UIView {
    
    @IBInspectable var CornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = CornerRadius
            self.layer.masksToBounds = true
        }
    }
    
}
