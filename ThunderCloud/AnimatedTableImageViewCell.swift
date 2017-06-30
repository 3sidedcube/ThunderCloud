//
//  AnimatedTableImageViewCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 30/06/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation

/// `TSCAnimatedTableImageViewCell` is a cell that loops through a number of images.
@available(*, deprecated, message: "Please use `TSCAnimationTableViewCell` instead")
open class AnimatedTableImageViewCell : TableImageViewCell {
	
	/// An array of `UIImage`s for the cell to animate through
	open var images: [UIImage]?
	
	/// An array of time intervals to determine how long each image is displayed for
	open var delays: [TimeInterval]?
	
	/// The index for the currently displayed frame
	open var currentIndex: Int = 0
	
	private var timer: Timer?
	
	/// Restarts the cell's animations
	open func resetAnimations() {
		timer?.invalidate()
	}
	
	@objc private func nextImage() {
		
		guard let _images = images, let _delays = delays, _images.count <= currentIndex else { return }
		
		let image = _images[currentIndex]
		cellImageView.image = image
		
		if _delays.count > currentIndex {
			
			let delay = _delays[currentIndex]/1000
			timer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(nextImage), userInfo: nil, repeats: false)
		} else {
			timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(nextImage), userInfo: nil, repeats: false)
		}
		
		if currentIndex != _images.count - 1 {
			currentIndex += 1
		} else {
			currentIndex = 0
		}
	}
}
