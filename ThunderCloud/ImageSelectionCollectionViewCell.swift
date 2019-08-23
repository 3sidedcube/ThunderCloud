//
//  ImageSelectionCollectionViewCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 11/08/2017.
//  Copyright © 2017 3sidedcube. All rights reserved.
//

import UIKit
import ThunderBasics
import ThunderTable

class ImageSelectionCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var labelContainerView: UIView!
	
	override func awakeFromNib() {
		
		super.awakeFromNib()
        
        imageView.borderColor = ThemeManager.shared.theme.mainColor
        imageView.cornerRadius = 8.0
        labelContainerView.cornerRadius = 8.0
        
        clipsToBounds = false
        contentView.clipsToBounds = false
	}
	
	override var isSelected: Bool {
		didSet {
			guard oldValue != isSelected else { return }
			
			imageView.borderWidth = isSelected ? 2 : 0
            labelContainerView.backgroundColor = isSelected ? ThemeManager.shared.theme.mainColor : .clear
            label.font = ThemeManager.shared.theme.dynamicFont(ofSize: 15, textStyle: .body, weight: isSelected ? .bold : .regular)
            label.textColor = isSelected ? .white : ThemeManager.shared.theme.darkGrayColor
			
			if isSelected {
				
				let animation = CAKeyframeAnimation(keyPath: "transform")

				let scale1 = CATransform3DMakeScale(1, 1, 1)
				let scale2 = CATransform3DMakeScale(0.85, 0.85, 1)
				let scale3 = CATransform3DMakeScale(1.1, 1.1, 1)
				let scale4 = CATransform3DMakeScale(1.0, 1.0, 1)
				
				animation.values = [scale1, scale2, scale3, scale4]
				animation.fillMode = CAMediaTimingFillMode.forwards
				animation.isRemovedOnCompletion = true
				animation.duration = 0.5
				animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
				
				contentView.layer.add(animation, forKey: "popIn")
				
				let scaleAnimation = CABasicAnimation(keyPath: "borderWidth")
				scaleAnimation.duration = 0.09
				scaleAnimation.fromValue = 0.0
				scaleAnimation.toValue = 4.0
				imageView.layer.add(scaleAnimation, forKey: "animateBorder")
				
			} else {
				
				contentView.layer.removeAllAnimations()
				contentView.layer.transform = CATransform3DIdentity
			}
		}
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		imageView.borderWidth = 0
	}
}
