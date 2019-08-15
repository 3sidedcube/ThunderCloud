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

open class BadgeScrollerViewCell: CollectionCell {
    
    public var badges: [Badge]? {
        didSet {
            reload()
        }
    }
        
    override open func awakeFromNib() {
        super.awakeFromNib()
        let nib = UINib(nibName: "TSCBadgeScrollerItemViewCell", bundle: Bundle(for: BadgeScrollerViewCell.self))
        collectionView.register(nib, forCellWithReuseIdentifier: "Cell")
    }
    
    override open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return badges?.count ?? 0
    }
    
    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        guard let badges = badges else { return cell }
        
        let badge = badges[indexPath.item]
        
        if let badgeCell = cell as? BadgeScrollerItemViewCell {
            
            badgeCell.badgeImageView.accessibilityLabel = badge.iconAccessibilityLabel
            badgeCell.badgeImageView.image = badge.icon
            badgeCell.titleLabel.text = badge.title
            
            if let title = badgeCell.titleLabel.text, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                badgeCell.titleContainerView.isHidden = false
            } else {
                badgeCell.titleContainerView.isHidden = true
            }
            
            let hasEarnt = badge.id != nil ? BadgeController.shared.hasEarntBadge(with: badge.id!) : false
            badgeCell.badgeImageView.alpha = hasEarnt ? 1.0 : 0.44
        }
        
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let badges = badges else {
            return CGSize.zero
        }
        
        let badge = badges[indexPath.item]
        return BadgeScrollerItemViewCell.sizeFor(badge: badge)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let badge = badges?[indexPath.item], let badgeId = badge.id else {
            return
        }
        
        if BadgeController.shared.hasEarntBadge(with: badgeId) {
            
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
}
