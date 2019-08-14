//
//  StormImage.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 14/08/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import Foundation

/// A structural representation of a storm `Image`, converted to UIKit UIImage and accessibility label
public struct StormImage {
    
    /// The actual image which can be used when rendering content
    public let image: UIImage
    
    /// An accessibility label which can be applied to `UIImageView` instances containing this image
    public let accessibilityLabel: String?
}
