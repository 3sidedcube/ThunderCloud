//
//  AnimationListItemCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 07/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// `AnimationListItemCell` is a cell that loops through a number of `TSCAnimationFrame`s to create an animation
open class AnimationListItemCell: TableImageViewCell {

	/// The animation to display
	public var animation: TSCAnimation?
	
	/// The index of the currently displayed frame in the animation
	public var currentIndex: Int = 0
	
	private var timer: Timer?
	
	/// Restarts the cell's animation
	public func resetAnimation() {
		
		timer?.invalidate()
		nextImage()
	}
	
	@objc private func nextImage() {
		
		guard let animation = animation, currentIndex < animation.animationFrames.count else { return }
		
		let currentFrame = animation.animationFrames[currentIndex]
		cellImageView.image = currentFrame.image
		
		if animation.animationFrames.count > currentIndex {
			
			if animation.animationFrames.count == currentIndex + 1 && !animation.looped {
				return
			}
			
			let delay = currentFrame.delay.doubleValue / 1000
			timer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(nextImage), userInfo: nil, repeats: false)
			
		} else if animation.looped {
			
			timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(nextImage), userInfo: nil, repeats: false)
		}
		
		if currentIndex != animation.animationFrames.count - 1 {
			currentIndex = currentIndex + 1
		} else {
			currentIndex = 0
		}
	}
}
