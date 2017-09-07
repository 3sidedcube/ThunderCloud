//
//  ToggleableListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// `ToggleableListItem` is an `EmbeddedLinksListItem` which when the row is selected, opens/closes up to reveal/hide more content
class ToggleableListItem: EmbeddedLinksListItem {
	
	/// Whether the row is displaying it's hidden content
	var isFullyVisible: Bool = false
	
	override func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		
		super.configure(cell: cell, at: indexPath, in: tableViewController)
		
		guard let toggleCell = cell as? ToggleableListItemCell else { return }
		
		toggleCell.isFullyVisible = isFullyVisible
	}
	
	override var cellClass: AnyClass? {
		return ToggleableListItemCell.self
	}
	
	override func handleSelection(of row: Row, at indexPath: IndexPath, in tableView: UITableView) {
		
		if link != nil {
			super.handleSelection(of: row, at: indexPath, in: tableView)
		} else {
			isFullyVisible = !isFullyVisible
			tableView.reloadRows(at: [indexPath], with: .automatic)
		}
	}
	
	var accessoryType: UITableViewCellAccessoryType? {
		get {
			return UITableViewCellAccessoryType.none
		}
		set {}
	}
	
	override open var selectionStyle: UITableViewCellSelectionStyle? {
		get {
			return UITableViewCellSelectionStyle.default
		}
		set {}
	}
}
