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
		
		
	}
}
