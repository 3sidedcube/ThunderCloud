//
//  OrderedListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// `OrderedListItem` is a subclass of `EmbeddedLinksListItem` which represents a row with a number on the left. They will always be correctly ordered from the CMS (1, 2, 3...)
class OrderedListItem: EmbeddedLinksListItem {
	
	/// The number to be displayed on the row
	var number: String?
	
	required init(dictionary: [AnyHashable : Any], parentObject: StormObjectProtocol?) {
		super.init(dictionary: dictionary, parentObject: parentObject)
		number = dictionary["annotation"] as? String
	}
	
	override var cellClass: AnyClass? {
		return NumberedViewCell.self
	}
	
	override func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		
		guard let numberCell = cell as? NumberedViewCell else { return }
		
		numberCell.numberLabel.text = number
	}
}
