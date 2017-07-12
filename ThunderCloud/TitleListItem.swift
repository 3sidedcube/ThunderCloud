//
//  TitleListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// `TitleListItem` is a subclass of `EmbeddedLinksListItem`, it represents a table item that has a title and an image.
/// It is an adapter object for the object in the cms, all logic is done in it's superclass
class TitleListItem: EmbeddedLinksListItem {
	var accessoryType: UITableViewCellAccessoryType? {
		return link != nil ? .disclosureIndicator : .none
	}
}
