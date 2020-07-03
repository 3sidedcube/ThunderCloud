//
//  UIFont+Components.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 01/07/2020.
//  Copyright © 2020 threesidedcube. All rights reserved.
//

import Foundation
import ThunderTable

public extension UIFont {
    
    /// `UIFont.Components` represents all the properties required to re-create a dynamic `UIFont` instance
    /// from `Theme`
    struct Components {
        
        public let baseFontSize: CGFloat
        
        public let textStyle: UIFont.TextStyle
        
        public let weight: UIFont.Weight
        
        /// Default memberwise initialiser for font components
        /// - Parameters:
        ///   - size: The base font size of the font
        ///   - textStyle: The text style for scaling the font
        ///   - weight: The weight of the font. Defaults to `.regular`
        public init(size: CGFloat, textStyle: UIFont.TextStyle, weight: UIFont.Weight = .regular) {
            self.baseFontSize = size
            self.textStyle = textStyle
            self.weight = weight
        }
    }
}

public extension Theme {
    
    /// Returns a dynamic font for the provided font components
    /// - Parameter fontComponents: The components of the font
    /// - Returns: A `UIFont` instance
    func dynamicFont(from fontComponents: UIFont.Components) -> UIFont {
        return dynamicFont(
            ofSize: fontComponents.baseFontSize,
            textStyle: fontComponents.textStyle,
            weight: fontComponents.weight
        )
    }
}
