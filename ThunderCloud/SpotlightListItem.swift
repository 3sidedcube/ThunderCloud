//
//  SpotlightListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 06/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

open class SpotlightListItem: ListItem, SpotlightListItemCellDelegate {
    
    /// An array of `Spotlight`s to be displayed
    public var spotlights: [SpotlightObjectProtocol]?
    
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
    
    open override var displaySeparators: Bool {
        get {
            return false
        }
        set { }
    }
    
    override open func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        
        cell.contentView.backgroundColor = .clear
        cell.backgroundColor = .clear
        cell.contentView.clipsToBounds = false
        cell.clipsToBounds = false
        
        super.configure(cell: cell, at: indexPath, in: tableViewController)
        
        guard let spotlightCell = cell as? SpotlightListItemCell else { return }
        
        spotlightCell.spotlights = spotlights
        spotlightCell.delegate = self
        spotlightCell.pageIndicatorBottomConstraint.constant = (spotlights?.count ?? 0) > 1 ? SpotlightListItemCell.bottomMargin : 0
        
        let availableWidth = tableViewController.view.frame.width - (SpotlightListItemCell.itemSpacing * 2) - (SpotlightListItemCell.itemOverhang * 2)
        
        if let height = height(constrainedTo: availableWidth) {
            spotlightCell.spotlightHeightConstraint?.constant = height
        } else {
            spotlightCell.spotlightHeightConstraint?.constant = 0
        }
    }
    
    open func height(constrainedTo width: CGFloat) -> CGFloat? {
        guard let spotlights = spotlights else { return nil }
        var sizes = spotlights.compactMap({ SpotlightCollectionViewCell.size(for: $0, constrainedTo: CGSize(width: width, height: .greatestFiniteMagnitude)) })
        sizes.sort { (size1, size2) -> Bool in
            return size1.height > size2.height
        }
        return sizes.first?.height
    }
    
    override open var estimatedHeight: CGFloat? {
        return height(constrainedTo: UIScreen.main.bounds.width)
    }
    
    open func spotlightCell(cell: SpotlightListItemCell, didReceiveTapOnItem atIndex: Int) {
        
        guard let spotlights = spotlights, spotlights.count > atIndex else { return }
        let spotlight = spotlights[atIndex]
        guard let link = spotlight.link else { return }
        
        self.link = link
        parentNavigationController?.push(link: link)
        
        NotificationCenter.default.sendAnalyticsHook(.spotlightClick(spotlight))
    }
}
