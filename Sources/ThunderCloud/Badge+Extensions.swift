//
//  Badge+Extensions.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 02/07/2020.
//  Copyright © 2020 threesidedcube. All rights reserved.
//

import Foundation
import UIKit
import ThunderBasics

public extension Badge {
    
    /// Map property `backgroundImageColor` to a `UIColor`
    var backgroundColor: UIColor? {
        guard let hex = backgroundImageColor else { return nil }
        return UIColor(hexString: hex)
    }
}
