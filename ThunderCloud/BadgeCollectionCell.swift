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
    
    
    override public var accessibilityLabel: String? {
        get {
            let params = [
                "BADGE_NAME": itemTitle ?? "Unknown".localised(with: "_BADGE_UNKNOWN")
            ]
            return enabled ?
                "{BADGE_NAME}. Earned.".localised(with: "_BADGE_EARNED", paramDictionary: params) :
                "{BADGE_NAME}. Not earned.".localised(with: "_BADGE_NOT_EARNED", paramDictionary: params)
        }
        set { }
    }
    
    public override var accessibilityHint: String? {
        get {
            guard enabled else { return nil }
            return "Double tap to share".localised(with: "_BADGE_PASSED_ACCESSIBILITYHINT")
        }
        set { }
    }
    
    public override var accessibilityTraits: UIAccessibilityTraits {
        get {
            return [.button]
        }
        set { }
    }
}

open class BadgeCollectionCell: CollectionCell {
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let badge = items?[indexPath.item] as? Badge, badge.enabled else {
            return
        }

        let viewController = UIApplication.visibleViewController
        viewController?.shareBadge(
            badge,
            defaultShareMessage: "Badge Earnt".localised(with: "_TEST_COMPLETED_SHARE")
        ) { activityType, completed, _, _ in
            NotificationCenter.default.sendAnalyticsHook(
                .badgeShare(badge, (
                    from: "BadgeScroller",
                    destination: activityType,
                    shared: completed
                ))
            )
        }
    }
}
