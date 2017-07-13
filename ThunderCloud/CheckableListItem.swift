//
//  CheckableListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// `CheckableListItem` is a subclass of `EmbeddedLinksListItem`, it represents a table item that can be checked. It is rendered out as a `EmbeddedLinksInputCheckItemCell`
class CheckableListItem: EmbeddedLinksListItem {

	/// The unique identifier of the cell
	/// This is used for saving the state of the checked cell to UserDefaults
	var checkIdentifier: NSNumber?
	
	required init(dictionary: [AnyHashable : Any]) {
		
		super.init(dictionary: dictionary)
		
		checkIdentifier = dictionary["id"] as? NSNumber
		if checkIdentifier == nil, let checkId = dictionary["id"] as? Int {
			checkIdentifier = NSNumber(value: checkId)
		}
	}
	
	override var cellClass: AnyClass? {
		return EmbeddedLinksInputCheckItemCell.self
	}
	
	override func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		super.configure(cell: cell, at: indexPath, in: tableViewController)
		guard let checkCell = cell as? EmbeddedLinksInputCheckItemCell else { return }
		checkCell.checkView.checkIdentifier = checkIdentifier
	}
	
	var accessoryType: UITableViewCellAccessoryType? {
		return .none
	}
	
	var selectionStyle: UITableViewCellSelectionStyle? {
		return .default
	}
}
