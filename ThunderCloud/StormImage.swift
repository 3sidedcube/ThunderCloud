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
    
    /// The image file extensions that are allowed by storm
    static let validExtensions: [String] = ["jpg", "jpeg", "png"]
    
    /// The actual image which can be used when rendering content
    public let image: UIImage
    
    /// An accessibility label which can be applied to `UIImageView` instances containing this image
    public let accessibilityLabel: String?
    
    /// Allocates a new image with the given `UIImage` and accessibility text
    /// - Parameter image: The image this storm image represents
    /// - Parameter accessibilityLabel: An accessibility label describing the image
    public init(image: UIImage, accessibilityLabel: String?) {
        self.image = image
        self.accessibilityLabel = accessibilityLabel
    }
}
