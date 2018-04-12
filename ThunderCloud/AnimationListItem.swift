//
//  AnimationListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 07/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// A subclass of `ImageListItem` which displays an array of animated images, delaying each one by a defined amount of time
class AnimationListItem: ImageListItem {

	/// The animation object that contains frame information
	var animation: Animation?
	
	required init(dictionary: [AnyHashable : Any]) {
		
		super.init(dictionary: dictionary)
		
		guard let animationDict = dictionary["animation"] as? [AnyHashable : Any] else { return }
		
		animation = Animation(dictionary: animationDict)
	}
	
	override var cellClass: UITableViewCell.Type? {
		return AnimationListItemCell.self
	}
	
	override func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		
		super.configure(cell: cell, at: indexPath, in: tableViewController)
		
		guard let animationCell = cell as? AnimationListItemCell else {
			super.configure(cell: cell, at: indexPath, in: tableViewController)
			return
		}
		
		animationCell.animation = animation
		animationCell.resetAnimation()		
	}
}
