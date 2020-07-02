//
//  ShadowComponents.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 01/07/2020.
//  Copyright © 2020 threesidedcube. All rights reserved.
//

import Foundation

public extension UIView {
    
    /// Component representation of all properties required to render a shadow in UIKit
    struct ShadowComponents {
        
        /// The blur radius of the shadow
        let radius: CGFloat
        
        /// The opacity of the shadow
        let opacity: Float
        
        /// The color of the shadow
        let color: UIColor
        
        /// The offset of the shadow
        let offset: CGPoint
        
        public init(radius: CGFloat, opacity: Float, color: UIColor, offset: CGPoint) {
            self.radius = radius
            self.opacity = opacity
            self.color = color
            self.offset = offset
        }
    }
    
    var shadow: ShadowComponents? {
        set {
            guard let newValue = newValue else {
                shadowRadius = 0
                shadowOpacity = 0
                shadowColor = nil
                shadowOffset = .zero
                return
            }
            shadowRadius = newValue.radius
            shadowOpacity = newValue.opacity
            shadowColor = newValue.color
            shadowOffset = newValue.offset
        }
        get {
            guard let shadowColor = shadowColor else {
                return nil
            }
            return ShadowComponents(
                radius: shadowRadius,
                opacity: shadowOpacity,
                color: shadowColor,
                offset: shadowOffset
            )
        }
    }
}
