//
//  AnimatedImageListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 05/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// Subclass of `ImageListItem` which displays an array of animated images at the aspect ratio of the first image in the set, delaying between each one by a defined amount of time
@available(*, deprecated, message: "Please use `AnimationListItem` instead")
open class AnimatedImageListItem: ImageListItem {
    
    public var frames: [(image: UIImage, delay: TimeInterval)] = []
    
    /// The array of images to animate
    public var images: [UIImage] = []
    
    /// An array of delays to apply between each consecutive frame
    public var delays: [TimeInterval] = []
    
    required public init(dictionary: [AnyHashable : Any]) {
        
        super.init(dictionary: dictionary)
        
        if let accessibilityLabelDict = dictionary["accessibilityLabel"] as? [AnyHashable : Any] {
            imageAccessibilityLabel = StormLanguageController.shared.string(for: accessibilityLabelDict)
        }
        
        guard let animatedImageDictionaries = dictionary["images"] as? [[AnyHashable : Any]] else { return }
        
        frames = animatedImageDictionaries.compactMap({ (animatedImageDict) -> (image: UIImage, delay: TimeInterval)? in
            
            guard let image = StormGenerator.image(fromJSON: animatedImageDict) else { return nil }
            guard let delay = animatedImageDict["delay"] as? TimeInterval else { return nil }
            
            return (image: image, delay: delay)
        })
    }
    
    override open var image: UIImage? {
        get {
            return frames.first?.image
        }
        set {
            super.image = newValue
        }
    }
    
    override open var cellClass: UITableViewCell.Type? {
        return AnimatedImageListCell.self
    }
    
    override open func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        
        super.configure(cell: cell, at: indexPath, in: tableViewController)
        guard let animatedCell = cell as? AnimatedImageListCell else { return }
        
        animatedCell.frames = frames
        animatedCell.resetAnimations()
        animatedCell.imageView?.accessibilityLabel = imageAccessibilityLabel
    }
}
