//
//  Cell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 30/06/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation

@objc(TSCEmbeddedLinksListItemCell)
/// `EmbeddedLinksListItemCell` is a `TableViewCell` that supports embedded links. Each link is displayed as a button.
open class EmbeddedLinksListItemCell: StormTableViewCell {
	
	/// An array of `TSCLink`s to be displayed
	open var links: [TSCLink]?
	
	private var unavailableLinks: [TSCLink]?
	
	/// A boolean to determine whether unavailable links should be hidden or not
	/// An unavailable link will be something like a call link on a device that can't make calls
	open var hideUnavailableLinks = false
	
	/// A selector which is called on the target when the row is selected
	open var selector: Selector?
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
