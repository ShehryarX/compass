//
//  UISwitchTintable.swift
//  Wander
//
//  Created by Shahbaz on 2019-09-14.
//  Copyright © 2019 Shahbaz Momi. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class UISwitchTintable: UISwitch {
    @IBInspectable var OffTint: UIColor? {
        didSet {
            self.tintColor = OffTint
            self.layer.cornerRadius = 16
            self.backgroundColor = OffTint
        }
    }
}
