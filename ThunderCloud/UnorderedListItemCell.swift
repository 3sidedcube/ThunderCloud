//
//  UnorderedListItemCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 05/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderBasics
import ThunderTable

/// `UnorderedListItemCell` is a subclass of `StormTableViewCell` it represents a cell that is in an unordered list such as a bulleted list
open class UnorderedListItemCell: StormTableViewCell {

	@IBOutlet weak private var bulletCenterVerticallyConstraint: NSLayoutConstraint?
	
	@IBOutlet weak private var bulletAlignTopConstraint: NSLayoutConstraint?
	
	/// The view which represents the bullet point
    @IBOutlet weak var bulletView: UIView! {
        didSet {
            bulletView.layer.cornerRadius = 5
            bulletView.layer.masksToBounds = true
        }
    }
	
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
		bulletView.backgroundColor = ThemeManager.shared.theme.mainColor
	}
	
	override open func layoutSubviews() {
		
		super.layoutSubviews()
		
		if cellDetailLabel?.text == nil, let text = cellDetailLabel?.text, text.isEmpty {
			bulletCenterVerticallyConstraint?.priority = UILayoutPriority(rawValue: 999)
			bulletAlignTopConstraint?.priority = UILayoutPriority(rawValue: 250)
		} else {
			bulletCenterVerticallyConstraint?.priority = UILayoutPriority(rawValue: 250)
			bulletAlignTopConstraint?.priority = UILayoutPriority(rawValue: 999)
		}
	}
}
