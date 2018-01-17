//
//  ToggleableListItemCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 05/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// `ToggleableListItemCell` is a subclass of `EmbeddedLinksListItemCell` which when selected opens up to reveal the detail text label.
open class ToggleableListItemCell: EmbeddedLinksListItemCell {

	/// Boolean to determine whether the cell is displaying the detail text label
	open var isFullyVisible: Bool = false {
		didSet {
			let bundle = Bundle(for: ToggleableListItemCell.self)
			if isFullyVisible {
				cellDetailLabel.isHidden = false
				embeddedLinksStackView.isHidden = false
				chevronImageView.image = UIImage(named: "chevron-up", in: bundle, compatibleWith: nil)
			} else {
				cellDetailLabel.isHidden = true
				embeddedLinksStackView.isHidden = true
				chevronImageView.image = UIImage(named: "chevron-down", in: bundle, compatibleWith: nil)
			}
		}
	}
	
	@IBOutlet weak private var chevronImageView: UIImageView!
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}
