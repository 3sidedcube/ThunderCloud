//
//  LogoListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// `LogoListItem` is a subclass of ListItem it is used to display company logos inside of an app. It is rendered out as a `LogoListItemViewCell`.
open class LogoListItem: ListItem {

	required public init(dictionary: [AnyHashable : Any], parentObject: StormObjectProtocol?) {
		super.init(dictionary: dictionary, parentObject: parentObject)
		
		guard let linkDictionary = dictionary["link"] as? [AnyHashable : Any], let titleDictionary = linkDictionary["title"] as? [AnyHashable : Any] else {
			return
		}
		
		title = TSCLanguageController.shared().string(for: titleDictionary)
	}
	
	override public var cellClass: AnyClass? {
		return LogoListItemCell.self
	}
}
