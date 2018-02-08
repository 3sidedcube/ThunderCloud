//
//  DescriptionListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// `DescriptionListItem` is a subclass of `EmbeddedLinksListItem` it reprents a table item that can have a title and a subtitle.
open class DescriptionListItem: EmbeddedLinksListItem {
	
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
