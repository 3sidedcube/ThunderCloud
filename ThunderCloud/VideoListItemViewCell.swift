//
//  VideoListItemViewCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 05/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// The cell that displays an image and play button to let the user know there is a video to play
open class VideoListItemViewCell: TableImageViewCell {

	@IBOutlet weak private var durationLabel: UILabel!
	
	@IBOutlet weak private var gradientImageView: UIImageView!
		
	/// The animated play button
	@IBOutlet weak var playButton: AnnularPlayButton!
	
	/// The length of the video in seconds
	public var duration: TimeInterval? {
		didSet {
			updateDurationLabelText()
		}
	}
	
	override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
	
	override open func awakeFromNib() {
		super.awakeFromNib()
	}
	
	func setup() {
		durationLabel?.font = ThemeManager.shared.theme.font(ofSize: 16)
	}
	
	override open func layoutSubviews() {
		super.layoutSubviews()
		
		if superview != nil {
			playButton.startAnimation(with: 0.2)
		}
		
		if let duration = duration, duration > 0 {
			
			durationLabel.isHidden = false
			gradientImageView.isHidden = false
		} else {
			
			durationLabel.isHidden = true
			gradientImageView.isHidden = true
		}
	}
	
	private func updateDurationLabelText() {
		
		guard let duration = duration else {
			durationLabel?.text = nil
			return
		}
		
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .positional
		formatter.allowedUnits = [ .minute, .second ]
		formatter.zeroFormattingBehavior = [ .pad ]
		
		durationLabel?.text = formatter.string(from: duration)
	}
}
