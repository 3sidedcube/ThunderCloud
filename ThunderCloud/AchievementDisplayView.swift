//
//  AchievementDisplayView.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// A protocol to adhere to in order to be displayed when an achievement has been earned
public protocol AchievementDisplayable {
    /// A custom init method which AchievementDisplayable must conform to
    ///
    /// - Parameters:
    ///   - frame: The frame of the view
    ///   - image: The image to be displayed in the view
    ///   - subtitle: The subtitle to be shown in the view
    init(frame: CGRect, image: StormImage?, subtitle: String?)
}

/// A base view conforming to `AchievementDisplayable` which is used for
/// displaying an image and subtitle as a pop up, generally used for displaying
/// earned badges
open class AchievementDisplayView: UIView, AchievementDisplayable {
    
    /// A view representation of the subtitle, this is layed out under the image.
    public let subtitleLabel = UILabel()
    
    private let badgeImageView: UIImageView
    
    private let titleLabel = UILabel()
    
    /// Conformance to `AchievementDisplayable`
    ///
    /// - Parameters:
    ///   - frame: The frame of the view
    ///   - image: The image to display
    ///   - subtitle: The subtitle to display
    required public init(frame: CGRect, image: StormImage?, subtitle: String?) {
        
        badgeImageView = UIImageView(image: image?.image)
        badgeImageView.accessibilityLabel = image?.accessibilityLabel
        super.init(frame: frame)
        
        addSubview(badgeImageView)
        
        titleLabel.text = "Congratulations".localised(with: "_QUIZ_WIN_CONGRATULATION")
        titleLabel.textAlignment = .center
        titleLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 17, textStyle: .body)
        titleLabel.textColor = ThemeManager.shared.theme.darkGrayColor
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        addSubview(titleLabel)
        
        if let subtitle = subtitle {
            subtitleLabel.text = subtitle
        }
        subtitleLabel.textAlignment = .center
        subtitleLabel.backgroundColor = .clear
        subtitleLabel.font = titleLabel.font
        subtitleLabel.textColor = titleLabel.textColor
        subtitleLabel.isUserInteractionEnabled = false
        subtitleLabel.numberOfLines = 0
        subtitleLabel.lineBreakMode = .byWordWrapping
        addSubview(subtitleLabel)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        badgeImageView = UIImageView()
        super.init(coder: aDecoder)
    }
    
    /// Padding around the content of the achievement view
    static let contentEdgePadding = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
    
    /// Spacing between the achievement labels and the image view
    static let labelImageSpacing: CGFloat = 16.0
    
    override open func layoutSubviews() {
        
        super.layoutSubviews()
        
        badgeImageView.center = CGPoint(x: frame.width/2, y: frame.height/2)
        badgeImageView.backgroundColor = .white
        badgeImageView.cornerRadius = badgeImageView.bounds.width/2
        
        let availableSize = CGSize(width: frame.size.width - AchievementDisplayView.contentEdgePadding.left - AchievementDisplayView.contentEdgePadding.right, height: CGFloat.greatestFiniteMagnitude)
        let titleSize = titleLabel.sizeThatFits(availableSize)
        titleLabel.frame = CGRect(
            x: AchievementDisplayView.contentEdgePadding.left,
            y: badgeImageView.frame.minY - titleSize.height - AchievementDisplayView.labelImageSpacing,
            width: frame.width - AchievementDisplayView.contentEdgePadding.left - AchievementDisplayView.contentEdgePadding.right,
            height: titleSize.height
        )
        
        let size = subtitleLabel.sizeThatFits(availableSize)
        subtitleLabel.frame = CGRect(
            x: AchievementDisplayView.contentEdgePadding.left,
            y: badgeImageView.frame.maxY + AchievementDisplayView.labelImageSpacing,
            width: frame.size.width - AchievementDisplayView.contentEdgePadding.left - AchievementDisplayView.contentEdgePadding.right,
            height: size.height
        )
        
        centerSubviewsVertically()
    }
    
    func accessibilitySettingsDidChange() {
        
        titleLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 17, textStyle: .body)
        titleLabel.textColor = ThemeManager.shared.theme.darkGrayColor
        
        subtitleLabel.font = titleLabel.font
        subtitleLabel.textColor = titleLabel.textColor
        
        setNeedsLayout()
    }
}

