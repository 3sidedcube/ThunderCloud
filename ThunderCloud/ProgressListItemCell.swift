//
//  QuizProgressListItemCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 05/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// A table view cell which displays a title and a users progress through a set of quizzes (Or anything else for that matter)
open class ProgressListItemCell: TableViewCell {

	/// A label displaying the users progress through a set of quizzes
	@IBOutlet weak var progressLabel: TSCLabel!

	public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	open override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}
	
	private func setup() {
		
		cellTextLabel.adjustsFontSizeToFitWidth = true
		cellTextLabel.font = ThemeManager.shared.theme.font(ofSize: 17)
		
		cellDetailLabel.textColor = .gray
		
		progressLabel.font = ThemeManager.shared.theme.boldFont(ofSize: 15)
		progressLabel.text = "1 / 1"
	}
}
