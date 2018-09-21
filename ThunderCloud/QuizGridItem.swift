//
//  QuizGridItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 16/02/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import UIKit
import ThunderCollection

/// Used to display a quiz badge in a collection view
open class QuizGridItem: StandardGridItem {
	
	public var badgeId: String?

	public required init?(dictionary: [AnyHashable : Any]) {
		
		if let badgeId = dictionary["badgeId"] as? String {
			self.badgeId = badgeId
		} else if let badgeId = dictionary["badgeId"] as? Int {
			self.badgeId = "\(badgeId)"
		}
		
		super.init(dictionary: dictionary)
		
		if let badgeId = badgeId, let badge = BadgeController.shared.badge(for: badgeId) {
			image = badge.icon
		}
	}
    
    open override func configure(cell: UICollectionViewCell, at indexPath: IndexPath, in collectionViewController: CollectionViewController) {
        
        super.configure(cell: cell, at: indexPath, in: collectionViewController)
        
        guard let standardCell = cell as? StandardGridItemCell else { return }
        
        let hasEarnedBadge = BadgeController.shared.hasEarntBadge(with: badgeId)
            
        standardCell.imageView?.alpha = hasEarnedBadge ? 1.0 : 0.25
        standardCell.imageView?.contentMode = .scaleAspectFit
    }
}
