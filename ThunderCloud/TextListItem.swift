//
//  TextListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// `TextListItem` is a subclass of `ListItem` which represents a row with just a subtitle.
/// It is normally used for displaying multiple lines of text.
/// Note it is an adapter for the object in the cms, all logic is done on it's superclass
open class TextListItem: ListItem {
	
	required public init(dictionary: [AnyHashable : Any]) {
		super.init(dictionary: dictionary)
		titleTextColor = .darkGray
	}
	
	open var accessoryType: UITableViewCellAccessoryType? {
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
	
	override open var cellClass: AnyClass? {
		return TextListItemCell.self
	}
}
