//
//  TextListItemCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 07/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// `TextListItemCell` is a cell that just displays the detail text label. Normally used for multiple lines of text.
open class TextListItemCell: StormTableViewCell {
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
		
		cellDetailLabel?.font = ThemeManager.shared.theme.font(ofSize: 18)
		cellDetailLabel?.textAlignment = .center
	}
}
