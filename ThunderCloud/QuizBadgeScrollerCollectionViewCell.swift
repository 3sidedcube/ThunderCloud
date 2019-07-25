//
//  QuizBadgeScrollerCollectionViewCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 03/05/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import UIKit

/// `QuizBadgeScrollerCollectionViewCell` is a `UICollectionViewCell` that represents a badge in a collection view
open class QuizBadgeScrollerCollectionViewCell: UICollectionViewCell {
    
    /// The image view for the badge's icon
    public let badgeImageView: UIImageView = UIImageView()
    
    /// A boolean used to set if the badge has been unlocked or not
    open var hasUnlockedBadge: Bool = false {
        didSet {
            badgeImageView.alpha = hasUnlockedBadge ? 1.0 : 0.4
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(badgeImageView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        let badgeImageInsets = UIEdgeInsets(top: 18, left: 15, bottom: 25, right: 15)
        let imageSize = min(
            contentView.bounds.width - badgeImageInsets.left - badgeImageInsets.right,
            contentView.bounds.height - badgeImageInsets.top - badgeImageInsets.bottom
        )
        badgeImageView.frame = CGRect(
            x: badgeImageInsets.left,
            y: badgeImageInsets.top,
            width: imageSize,
            height: imageSize
        )
        badgeImageView.center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        
        badgeImageView.alpha = hasUnlockedBadge ? 1.0 : 0.4
    }
}
