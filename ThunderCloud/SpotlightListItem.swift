//
//  SpotlightListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 06/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

open class SpotlightListItem: ListItem {
	
	/// An array of `Spotlight`s to be displayed
	public var spotlights: [Spotlight]?
	
	required public init(dictionary: [AnyHashable : Any]) {
		
		super.init(dictionary: dictionary)
		
		guard let imagesArray = dictionary["spotlights"] as? [[AnyHashable : Any]] else { return }
		
		spotlights = imagesArray.map({ (spotlightDict) -> Spotlight in
			return Spotlight(dictionary: spotlightDict)
		})
	}
	
	override public var cellClass: AnyClass? {
		return SpotlightListItemCell.self
	}
	
	var accessoryType: UITableViewCellAccessoryType? {
		return .none
	}
	
	var selectionStyle: UITableViewCellSelectionStyle? {
		return .none
	}
	
	override public func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		
		super.configure(cell: cell, at: indexPath, in: tableViewController)
		
		guard let spotlightCell = cell as? SpotlightListItemCell else { return }
		
		super.configure(cell: cell, at: indexPath, in: tableViewController)
		spotlightCell.spotlights = spotlights
		spotlightCell.delegate = self
	}
}

extension SpotlightListItem: SpotlightListItemCellDelegate {
	
	public func spotlightCell(cell: SpotlightListItemCell, didReceiveTapOnItem atIndex: Int) {
		
		guard let _spotlights = spotlights, _spotlights.count > atIndex else { return }
		let spotlight = _spotlights[atIndex]
		guard let link = spotlight.link else { return }
		
		self.link = link
		parentNavigationController?.push(link)
		NotificationCenter.default.sendStatEventNotification(category: "Spotlight", action: spotlight.link?.url?.absoluteString ?? "Unkown link", label: nil, value: nil, object: self)
	}
}
