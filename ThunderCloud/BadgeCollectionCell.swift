//
//  TSCBadgeScrollerViewCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 20/09/2016.
//  Copyright © 2016 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

import UIKit

extension Badge: CollectionCellDisplayable {
    
    public var itemTitle: String? {
        return title
    }
    
    public var itemImage: StormImage? {
        return icon
    }
    
    public var enabled: Bool {
        return BadgeController.shared.hasEarntBadge(with: id)
    }
}

open class BadgeCollectionCell: CollectionCell {
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let badge = items?[indexPath.item] as? Badge, badge.enabled else {
            return
        }
                
        let defaultShareBadgeMessage = "Badge Earnt".localised(with: "_TEST_COMPLETED_SHARE")
        
        var items: [Any] = []
        
        if let icon = badge.icon {
            items.append(icon)
        }
        
        items.append(badge.shareMessage ?? defaultShareBadgeMessage)
        
        let shareViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        shareViewController.excludedActivityTypes = [.saveToCameraRoll, .print, .assignToContact]
        
        let keyWindow = UIApplication.shared.keyWindow
        shareViewController.popoverPresentationController?.sourceView = keyWindow
        if let window = keyWindow {
            shareViewController.popoverPresentationController?.sourceRect = CGRect(x: window.center.x, y: window.frame.maxY, width: 100, height: 100)
        }
        shareViewController.popoverPresentationController?.permittedArrowDirections = [.up]
        
        shareViewController.completionWithItemsHandler = { (activityType, completed, returnedItems, activityError) in
            NotificationCenter.default.sendAnalyticsHook(.badgeShare(badge, (from: "BadgeScroller", destination: activityType, shared: completed)))
        }
        
        parentViewController?.present(shareViewController, animated: true, completion: nil)
    }
}
