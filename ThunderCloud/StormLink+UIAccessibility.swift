//
//  StormLink+UIAccessibility.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 13/12/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import Foundation

extension StormLink {
    
    override open var accessibilityTraits: UIAccessibilityTraits {
        get {
            // If linkClass is a `uri` link, then read it as so!
            return linkClass == .uri ? [.link] : [.button]
        }
        set { }
    }
    
    open override var accessibilityHint: String? {
        get {
            guard linkClass == .uri else {
                return nil
            }
            return "Double tap to open in an external browser".localised(with: "_STORMLINK_URI_HINT")
        }
        set { }
    }
}
