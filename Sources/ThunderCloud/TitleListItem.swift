//
//  TitleListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// `TitleListItem` is a subclass of `ListItem`, it represents a table item that has a title and an image.
/// It is an adapter object for the object in the cms, all logic is done in it's superclass
open class TitleListItem: ListItem {
	override open var accessoryType: UITableViewCell.AccessoryType? {
		get {
            return link != nil ? .disclosureIndicator : UITableViewCell.AccessoryType.none
		}
		set {}
	}
}
