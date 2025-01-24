//
//  QuizProgressListItemCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 05/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderBasics
import ThunderTable

/// A table view cell which displays a title and a users progress through a set of quizzes (Or anything else for that matter)
open class ProgressListItemCell: StormTableViewCell {

	/// A label displaying the users progress through a set of quizzes
    @IBOutlet public weak var progressLabel: TSCLabel! {
        didSet {
            progressLabel.layer.cornerRadius = 4
            progressLabel.layer.masksToBounds = true
        }
    }

    @IBOutlet public weak var subtitleLeftConstraint: NSLayoutConstraint!
    
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override open func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}
	
	private func setup() {
		
		cellTextLabel?.adjustsFontSizeToFitWidth = true
		cellTextLabel?.font = ThemeManager.shared.theme.dynamicFont(ofSize: 17, textStyle: .body)
		
		cellDetailLabel?.textColor = ThemeManager.shared.theme.darkGrayColor
		
		progressLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 15, textStyle: .callout, weight: .bold)
		progressLabel.text = "1 / 1"
	}
}
