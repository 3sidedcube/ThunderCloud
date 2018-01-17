//
//  UnorderedListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// `UnorderedListItem` is a subclass of `EmbeddedLinksListItem` which represents a table item in an unordered list. Normally used in a bulleted list.
class UnorderedListItem: EmbeddedLinksListItem {

	override var cellClass: AnyClass? {
		return UnorderedListItemCell.self
	}
	
	override open var accessoryType: UITableViewCellAccessoryType? {
		get {
			return UITableViewCellAccessoryType.none
		}
		set {}
	}
	
	override open var selectionStyle: UITableViewCellSelectionStyle? {
		get {
			return UITableViewCellSelectionStyle.none
		}
		set {}
	}
}
