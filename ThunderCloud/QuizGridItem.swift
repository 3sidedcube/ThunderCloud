//
//  QuizGridItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 16/02/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import UIKit

/// Used to display a quiz badge in a collection view
open class QuizGridItem: GridItem {
	
	let badgeId: String?

	public required init?(dictionary: [AnyHashable : Any]) {
		
		if let badgeId = dictionary["badgeId"] as? String {
			self.badgeId = badgeId
		} else if let badgeId = dictionary["badgeId"] as? Int {
			self.badgeId = "\(badgeId)"
		} else {
			badgeId = nil
		}
		
		super.init(dictionary: dictionary)
		
		if let badgeId = badgeId, let badge = BadgeController.shared.badge(for: badgeId) {
			image = badge.icon
		}
	}
}
