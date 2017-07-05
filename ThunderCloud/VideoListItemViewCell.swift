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
	@IBOutlet weak var playButton: TSCAnnularPlayButton!
	
	/// The length of the video in seconds
	public var duration: TimeInterval? {
		didSet {
			updateDurationLabelText()
		}
	}
	
	public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	open override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}
	
	func setup() {
		durationLabel.font = ThemeManager.shared.theme.font(ofSize: 16)
	}
	
	open override func layoutSubviews() {
		super.layoutSubviews()
		
		if let _duration = duration, _duration > 0 {
			
			durationLabel.isHidden = false
			cellTextLabel.isHidden = false
			gradientImageView.isHidden = false
		} else {
			
			durationLabel.isHidden = true
			cellTextLabel.isHidden = true
			gradientImageView.isHidden = true
		}
	}
	
	private func updateDurationLabelText() {
		
		guard let _duration = duration else {
			durationLabel.text = nil
			return
		}
		
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .positional
		formatter.allowedUnits = [ .minute, .second ]
		formatter.zeroFormattingBehavior = [ .pad ]
		
		durationLabel.text = formatter.string(from: _duration)
	}
}
