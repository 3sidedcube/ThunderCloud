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
	var checkIdentifier: String?
	
	required init(dictionary: [AnyHashable : Any], parentObject: StormObjectProtocol?) {
		super.init(dictionary: dictionary, parentObject: parentObject)
		
		checkIdentifier = dictionary["id"] as? String
		if checkIdentifier == nil, let checkId = dictionary["id"] as? Int {
			checkIdentifier = "\(checkId)"
		}
	}
	
	var cellClass: AnyClass? {
		return EmbeddedLinksInputCheckItemCell.self
	}
}
