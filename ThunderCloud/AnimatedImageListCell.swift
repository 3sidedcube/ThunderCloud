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
open class AnimatedImageListCell : TableImageViewCell {
	
	/// The frames of the animation
	open var frames: [(image: UIImage, delay: TimeInterval)]?
	
	/// The index for the currently displayed frame
	open var currentIndex: Int = 0
	
	private var timer: Timer?
	
	/// Restarts the cell's animations
	open func resetAnimations() {
		timer?.invalidate()
	}
	
	@objc private func nextImage() {
		
		guard let _frames = frames, _frames.count <= currentIndex else { return }
		
		let image = _frames[currentIndex].image
		cellImageView.image = image
		
		if _frames.count > currentIndex {
			
			let delay = _frames[currentIndex].delay/1000
			timer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(nextImage), userInfo: nil, repeats: false)
		} else {
			timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(nextImage), userInfo: nil, repeats: false)
		}
		
		if currentIndex != _frames.count - 1 {
			currentIndex += 1
		} else {
			currentIndex = 0
		}
	}
}
