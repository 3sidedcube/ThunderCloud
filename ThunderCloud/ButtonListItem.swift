//
//  ButtonListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// `ButtonListItem` is a subclass of `EmbeddedLinksItem`, it represents an item with a single button on it. 
/// It is rendered out as an `EmbeddedLinksListItemCell
open class ButtonListItem: EmbeddedLinksListItem {

	/// The target to call when the button is pressed
	public var target: AnyObject?
	
	/// The selector to call on target when the button is selected
	public var selector: Selector?
	
	/// Creates a new instance with a target and selector
	///
	/// - Parameters:
	///   - target: The object to have selector called on upon pressing button
	///   - selector: The selector to call on target when button pressed
	public init(target: AnyObject?, selector: Selector?) {
		
		super.init(dictionary: [:])
		self.target = target
		self.selector = selector
	}
	
	/// Creates a new instance with a custom title and button title
	///
	/// - Parameters:
	///   - title: The title to be displayed in the cell
	///   - buttonTitle: The title to be displayed on the button
	///   - target: The object to have selector called on upon pressing button
	///   - selector: The selector to call on target when button pressed
	public convenience init(title: String?, buttonTitle: String?, target: AnyObject?, selector: Selector?) {
		
		self.init(target: target, selector: selector)
		
		self.title = title
		let link = TSCLink()
		link.title = buttonTitle
		
		embeddedLinks = [link]
	}
	
	public required init(dictionary: [AnyHashable : Any]) {
		
		super.init(dictionary: dictionary)
		
		guard let buttonDict = dictionary["button"] as? [AnyHashable : Any], let linkDict = buttonDict["link"] as? [AnyHashable : Any], let link = TSCLink(dictionary: linkDict) else {
			return
		}
		
		if link.title == nil, let titleDict = buttonDict["title"] as? [AnyHashable : Any] {
			link.title = TSCStormLanguageController.shared().string(for: titleDict)
		}
		
		var links = embeddedLinks ?? []
		links.insert(link, at: 0)
		embeddedLinks = links
	}
	
	public override func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		
		super.configure(cell: cell, at: indexPath, in: tableViewController)
		
		guard let embeddedCell = cell as? EmbeddedLinksListItemCell else {
			return
		}
		guard let links = embeddedCell.links, links.count == 1 else {
			return
		}
		
		embeddedCell._target = target
		embeddedCell.selector = selector
	}
	
	var accessoryType: UITableViewCellAccessoryType? {
		get {
			return .none
		}
		set {}
	}
	
	var selectionStyle: UITableViewCellSelectionStyle? {
		get {
			return .none
		}
		set {}
	}
}
