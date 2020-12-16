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
        
        imageView.layer.borderColor = ImageOption.selectedColor.cgColor
        imageView.layer.cornerRadius = 8.0
        imageView.layer.masksToBounds = true
        labelContainerView.layer.cornerRadius = 8.0
        labelContainerView.layer.masksToBounds = true
        
        clipsToBounds = false
        contentView.clipsToBounds = false
    }
    
    override var isSelected: Bool {
        didSet {
            guard oldValue != isSelected else { return }

            let selectedColor = isSelected ? ImageOption.selectedColor : ImageOption.borderColor
            imageView.layer.borderWidth = isSelected ? ImageOption.selectedBorderWidth : 0
            labelContainerView.backgroundColor = selectedColor
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
        imageView.layer.borderWidth = 0
    }
    
    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            return isSelected ? [.selected, .button] : [.button]
        }
        set { }
    }
    
    override var isAccessibilityElement: Bool {
        get {
            return true
        }
        set { }
    }
    
    override var accessibilityLabel: String? {
        get {
            return [imageView.accessibilityLabel, label.text].compactMap({ $0 }).joined(separator: ",")
        }
        set { }
    }
    
    override var accessibilityHint: String? {
        get {
            return isSelected ?
                "Selectable. Double tap to de-select".localised(with: "_QUIZ_VOICEOVER_IMAGEITEM_HINT_SELECTED") :
                "Selectable. Double tap to select".localised(with: "_QUIZ_VOICEOVER_IMAGEITEM_HINT_UNSELECTED")
        }
        set { }
    }
}
