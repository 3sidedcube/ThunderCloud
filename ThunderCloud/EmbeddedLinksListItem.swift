//
//  EmbeddedLinksListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// Subclass of `ListItem` that allows embedded links, each link is displayed as a `UIButton`
class EmbeddedLinksListItem: ListItem {

	/// An array of `TSCLink`s to display in the list item
	var embeddedLinks: [TSCLink]?
	
	required init(dictionary: [AnyHashable : Any], parentObject: StormObjectProtocol?) {
		super.init(dictionary: dictionary, parentObject: parentObject)
		
		guard let linkDictionaries = dictionary["embeddedLinks"] as? [[AnyHashable : Any]] else {
			return
		}
		
		embeddedLinks = linkDictionaries.map({ (dictionary) -> TSCLink in
			return TSCLink(dictionary: dictionary)
		})
	}
}
