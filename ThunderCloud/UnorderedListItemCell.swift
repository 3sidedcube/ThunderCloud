//
//  UnorderedListItemCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 05/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// `UnorderedListItemCell` is a subclass of `EmbeddedLinksListItemCell` it represents a cell that is in an unordered list such as a bulleted list
class UnorderedListItemCell: EmbeddedLinksListItemCell {

	@IBOutlet weak private var bulletCenterVerticallyConstraint: NSLayoutConstraint!
	
	@IBOutlet weak private var bulletAlignTopConstraint: NSLayoutConstraint!
	
	/// The view which represents the bullet point
	@IBOutlet weak var bulletView: TSCView!
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}
	
	private func setup() {
		bulletView.backgroundColor = ThemeManager.shared.theme.mainColor
	}
	
	override func layoutSubviews() {
		
		super.layoutSubviews()
		
		if cellDetailLabel.text == nil || cellDetailLabel.text!.isEmpty {
			bulletCenterVerticallyConstraint.priority = UILayoutPriority(rawValue: 999)
			bulletAlignTopConstraint.priority = UILayoutPriority(rawValue: 250)
		} else {
			bulletCenterVerticallyConstraint.priority = UILayoutPriority(rawValue: 250)
			bulletAlignTopConstraint.priority = UILayoutPriority(rawValue: 999)
		}
	}
}
