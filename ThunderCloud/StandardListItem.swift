//
//  StandardListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// `StandardListItem` is a subclass of `EmbeddedLinksListItem` it represents a row with a title description and image. It is an adapter for the object in the CMS. All logic is done on it's super.
class StandardListItem: EmbeddedLinksListItem {
	
	var accessoryType: UITableViewCellAccessoryType? {
		get {
			
			if let url = link?.url {
				return url.absoluteString.isEmpty ? UITableViewCellAccessoryType.none : .disclosureIndicator
			}
			
			guard let linkClass = link?.linkClass, linkClass == "SmsLink", linkClass == "EmergencyLink", linkClass == "ShareLink", linkClass == "TimerLink" else { return UITableViewCellAccessoryType.none }
			
			return .disclosureIndicator
		}
		set {}
	}
}
