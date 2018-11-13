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
	
	override open var cellClass: UITableViewCell.Type? {
		return SpotlightListItemCell.self
	}
	
    override open var accessoryType: UITableViewCell.AccessoryType? {
        get {
            return UITableViewCell.AccessoryType.none
        }
        set { }
    }
	
    override open var selectionStyle: UITableViewCell.SelectionStyle? {
		return UITableViewCell.SelectionStyle.none
	}
	
	override open func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		
		super.configure(cell: cell, at: indexPath, in: tableViewController)
		
		guard let spotlightCell = cell as? SpotlightListItemCell else { return }
		
		spotlightCell.spotlights = spotlights
		spotlightCell.delegate = self
        
        if let imageHeight = imageHeight(constrainedTo: tableViewController.view.frame.width) {
            spotlightCell.heightConstraint?.constant = imageHeight
        } else {
            spotlightCell.heightConstraint?.constant = 160
        }
	}
    
    open func imageHeight(constrainedTo width: CGFloat) -> CGFloat? {
        guard let image = spotlights?.first?.image else { return nil }
        let aspectRatio = image.size.height / image.size.width
        return aspectRatio * width
    }
    
    override open var estimatedHeight: CGFloat? {
        return imageHeight(constrainedTo: UIScreen.main.bounds.width)
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
