//
//  OrderedListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// `OrderedListItem` is a subclass of `ListItem` which represents a row with a number on the left. They will always be correctly ordered from the CMS (1, 2, 3...)
open class OrderedListItem: ListItem {
	
	/// The number to be displayed on the row
	public var number: String?
	
	required public init(dictionary: [AnyHashable : Any]) {
		super.init(dictionary: dictionary)
		number = dictionary["annotation"] as? String
	}
	
	override open var cellClass: UITableViewCell.Type? {
		return NumberedViewCell.self
	}
	
	override open func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		
		super.configure(cell: cell, at: indexPath, in: tableViewController)
		
		guard let numberCell = cell as? NumberedViewCell else { return }
		numberCell.numberLabel.text = number
        numberCell.numberLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 28, textStyle: .title2, weight: .medium)
	}
	
	override open var accessoryType: UITableViewCell.AccessoryType? {
		get {
			return UITableViewCell.AccessoryType.none
		}
		set {}
	}
	
	override open var selectionStyle: UITableViewCell.SelectionStyle? {
		return UITableViewCell.SelectionStyle.none
	}
}
