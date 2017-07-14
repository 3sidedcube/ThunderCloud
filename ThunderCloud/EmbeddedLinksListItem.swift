//
//  EmbeddedLinksListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// Subclass of `ListItem` that allows embedded links, each link is displayed as a `UIButton`
open class EmbeddedLinksListItem: ListItem {

	/// An array of `TSCLink`s to display in the list item
	public var embeddedLinks: [TSCLink]?
	
	required public init(dictionary: [AnyHashable : Any]) {
		
		super.init(dictionary: dictionary)
		
		guard let linkDictionaries = dictionary["embeddedLinks"] as? [[AnyHashable : Any]] else {
			return
		}
		
		embeddedLinks = linkDictionaries.flatMap({ (dictionary) -> TSCLink? in
			return TSCLink(dictionary: dictionary)
		})
	}
	
	override public var cellClass: AnyClass? {
		return EmbeddedLinksListItemCell.self
	}
	
	override public func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		
		super.configure(cell: cell, at: indexPath, in: tableViewController)
		guard let embeddedLinksCell = cell as? EmbeddedLinksListItemCell else {
			return
		}
		
		// If we have no links make sure to get rid of the spacing on mainStackView
		if let links = embeddedLinks, links.count > 0 {
			embeddedLinksCell.mainStackView?.spacing = 12
		} else {
			embeddedLinksCell.mainStackView?.spacing = 0
		}
		
		embeddedLinksCell.links = embeddedLinks
	}
}
