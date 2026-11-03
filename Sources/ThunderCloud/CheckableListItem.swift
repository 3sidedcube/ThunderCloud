//
//  CheckableListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// `CheckableListItem` is a subclass of `ListItem`, it represents a table item that can be checked. It is rendered out as a `EmbeddedLinksInputCheckItemCell`
open class CheckableListItem: ListItem {

	/// The unique identifier of the cell
	/// This is used for saving the state of the checked cell to UserDefaults
	public var checkIdentifier: Int?
	
    required public init(dictionary: [AnyHashable : Any]) {
		
		super.init(dictionary: dictionary)
		checkIdentifier = dictionary["id"] as? Int
	}
	
    override open var cellClass: UITableViewCell.Type? {
		return EmbeddedLinksInputCheckItemCell.self
	}
	
    override open func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		super.configure(cell: cell, at: indexPath, in: tableViewController)
		guard let checkCell = cell as? EmbeddedLinksInputCheckItemCell else { return }
		checkCell.checkView.checkIdentifier = checkIdentifier
	}
	
	override open var accessoryType: UITableViewCell.AccessoryType? {
		get {
			return UITableViewCell.AccessoryType.none
		}
		set {}
	}
	
	override open var selectionStyle: UITableViewCell.SelectionStyle? {
		return UITableViewCell.SelectionStyle.default
	}
}
