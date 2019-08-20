//
//  UIAccessibility+ButtonShapes.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 20/08/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import UIKit

extension UIAccessibility {
    
    /// Returns whether button shapes are enabled by the user
    public static var buttonShapesEnabled: Bool {
        let button = UIButton()
        button.setTitle("Button Shapes", for: .normal)
        return button.titleLabel?.attributedText?.attribute(NSAttributedString.Key.underlineStyle, at: 0, effectiveRange: nil) != nil
    }
}
