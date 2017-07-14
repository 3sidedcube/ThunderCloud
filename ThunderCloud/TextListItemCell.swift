//
//  TextListItemCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 07/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// `TextListItemCell` is a cell that just displays the detail text label. Normally used for multiple lines of text.
class TextListItemCell: StormTableViewCell {
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}
	
	private func setup() {
		
		cellDetailLabel.font = ThemeManager.shared.theme.font(ofSize: 18)
		cellDetailLabel.textAlignment = .center
	}
}
