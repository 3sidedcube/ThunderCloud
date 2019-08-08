//
//  UnorderedListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// `UnorderedListItem` is a subclass of `EmbeddedLinksListItem` which represents a table item in an unordered list. Normally used in a bulleted list.
open class UnorderedListItem: ListItem {

	override open var cellClass: UITableViewCell.Type? {
		return UnorderedListItemCell.self
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
