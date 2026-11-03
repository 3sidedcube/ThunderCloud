//
//  DescriptionListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// `DescriptionListItem` is a subclass of `ListItem` it reprents a table item that can have a title and a subtitle.
open class DescriptionListItem: ListItem {
	
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
