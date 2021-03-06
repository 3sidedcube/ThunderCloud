//
//  StandardListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// `StandardListItem` is a subclass of `ListItem` it represents a row with a title description and image. It is an adapter for the object in the CMS. All logic is done on it's super.
open class StandardListItem: ListItem {
	
	override open var accessoryType: UITableViewCell.AccessoryType? {
		get {
			
			if let url = link?.url {
				return url.absoluteString.isEmpty ? UITableViewCell.AccessoryType.none : .disclosureIndicator
			}
			
			guard let linkClass = link?.linkClass, linkClass == .sms || linkClass == .emergency || linkClass == .share || linkClass == .timer else { return UITableViewCell.AccessoryType.none }
			
			return .disclosureIndicator
		}
		set {}
	}
}
