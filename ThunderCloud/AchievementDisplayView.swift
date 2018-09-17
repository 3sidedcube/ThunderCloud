//
//  AchievementDisplayView.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// A protocol to adhere to in order to be displayed when an achievement has been earned
public protocol AchievementDisplayable {
	/// A custom init method which AchievementDisplayable must conform to
	///
	/// - Parameters:
	///   - frame: The frame of the view
	///   - image: The image to be displayed in the view
	///   - subtitle: The subtitle to be shown in the view
	init(frame: CGRect, image: UIImage?, subtitle: String?)
}


@objc(TSCAchievementDisplayView)
/// A base view conforming to `AchievementDisplayable` which is used for
/// displaying an image and subtitle as a pop up, generally used for displaying
/// earned badges
open class AchievementDisplayView: UIView, AchievementDisplayable {
	
	/// A view representation of the subtitle, this is layed out under the image.
    public let subtitleLabel: UITextView = UITextView()
	
	private let badgeImageView: UIImageView
	
	private let titleLabel: UILabel = UILabel()

	/// Conformance to `AchievementDisplayable`
	///
	/// - Parameters:
	///   - frame: The frame of the view
	///   - image: The image to display
	///   - subtitle: The subtitle to display
	@objc required public init(frame: CGRect, image: UIImage?, subtitle: String?) {
		
		badgeImageView = UIImageView(image: image)
		super.init(frame: frame)
		
		addSubview(badgeImageView)
		
		titleLabel.text = "Congratulations".localised(with: "_QUIZ_WIN_CONGRATULATION")
		titleLabel.textAlignment = .center
		addSubview(titleLabel)
		
		if let subtitle = subtitle {
			subtitleLabel.text = subtitle
		}
		subtitleLabel.textAlignment = .center
		subtitleLabel.backgroundColor = .clear
		subtitleLabel.font = titleLabel.font
		addSubview(subtitleLabel)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		badgeImageView = UIImageView()
		super.init(coder: aDecoder)
	}
	
	override open func layoutSubviews() {
		
		super.layoutSubviews()
		
		badgeImageView.center = CGPoint(x: frame.width/2, y: frame.height/2)
		titleLabel.frame = CGRect(x: 0, y: 0, width: frame.width, height: badgeImageView.frame.minY)
		
		let size = subtitleLabel.sizeThatFits(CGSize(width: frame.size.width - 24, height: CGFloat.greatestFiniteMagnitude))
		subtitleLabel.frame = CGRect(x: 12, y: badgeImageView.frame.maxY, width: frame.size.width - 24, height: size.height + 20)
	}
}

