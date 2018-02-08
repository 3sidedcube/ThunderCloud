//
//  NumberedViewCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation

/// `NumberedViewCell` is used to display cells in an ordered list
open class NumberedViewCell: EmbeddedLinksListItemCell {
	
	/// A `UILabel` that displays the number of the cell. Sits on the left hand side of the cell.
	@IBOutlet weak public var numberLabel: UILabel!
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}
	
	override open func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	private func setup() {
		
		numberLabel.textColor = ThemeManager.shared.theme.freeTextColor
		numberLabel.font = ThemeManager.shared.theme.font(ofSize: 32)
		numberLabel.backgroundColor = .clear
		numberLabel.adjustsFontSizeToFitWidth = true
	}
}
