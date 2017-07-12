//
//  AnimatedImageListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 05/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// Subclass of `ImageListItem` which displays an array of animated images at the aspect ratio of the first image in the set, delaying between each one by a defined amount of time
@available(*, deprecated, message: "Please use `AnimationListItem` instead")
open class AnimatedImageListItem: ImageListItem {
	
	public var frames: [(image: UIImage, delay: TimeInterval)] = []
	
	/// The array of images to animate
	public var images: [UIImage] = []
	
	/// An array of delays to apply between each consecutive frame
	public var delays: [TimeInterval] = []
	
	required public init(dictionary: [AnyHashable : Any], parentObject: StormObjectProtocol?) {
		
		super.init(dictionary: dictionary, parentObject: parentObject)
		
		guard let animatedImageDictionaries = dictionary["images"] as? [[AnyHashable : Any]] else { return }
		
		frames = animatedImageDictionaries.flatMap({ (animatedImageDict) -> (image: UIImage, delay: TimeInterval)? in
			
			guard let image = TSCImage.image(with: animatedImageDict) else { return nil }
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
	
	override public var cellClass: AnyClass? {
		return AnimatedImageListCell.self
	}
	
	override public func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		
		super.configure(cell: cell, at: indexPath, in: tableViewController)
		guard let animatedCell = cell as? AnimatedImageListCell else { return }
		
		animatedCell.frames = frames
		animatedCell.resetAnimations()
	}
}
