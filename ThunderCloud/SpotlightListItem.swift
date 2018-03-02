//
//  SpotlightListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 06/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

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
	
	override open var cellClass: AnyClass? {
		return SpotlightListItemCell.self
	}
	
	override open var accessoryType: UITableViewCellAccessoryType? {
		get {
			return UITableViewCellAccessoryType.none
		}
		set {}
	}
	
	override open var selectionStyle: UITableViewCellSelectionStyle? {
		return UITableViewCellSelectionStyle.none
	}
	
	override open func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		
		super.configure(cell: cell, at: indexPath, in: tableViewController)
		
		guard let spotlightCell = cell as? SpotlightListItemCell else { return }
		
		super.configure(cell: cell, at: indexPath, in: tableViewController)
		spotlightCell.spotlights = spotlights
		spotlightCell.delegate = self
	}
}

extension SpotlightListItem: SpotlightListItemCellDelegate {
	
	public func spotlightCell(cell: SpotlightListItemCell, didReceiveTapOnItem atIndex: Int) {
		
		guard let spotlights = spotlights, spotlights.count > atIndex else { return }
		let spotlight = spotlights[atIndex]
		guard let link = spotlight.link else { return }
		
		self.link = link
		parentNavigationController?.push(link: link)
		NotificationCenter.default.sendStatEventNotification(category: "Spotlight", action: spotlight.link?.url?.absoluteString ?? "Unkown link", label: nil, value: nil, object: self)
	}
}
