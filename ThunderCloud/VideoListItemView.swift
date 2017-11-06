//
//  VideoListItemView.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 05/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// Storm representation of a video view
open class VideoListItemView: ImageListItem {

	/// The length of the video
	open var duration: TimeInterval?
	
	required public init(dictionary: [AnyHashable : Any]) {
		
		super.init(dictionary: dictionary)
		
		// Duration is done in milliseconds due to Android
		if let duration = dictionary["duration"] as? TimeInterval {
			self.duration = duration/1000
		}
		
		if let attributes = dictionary["attributes"] as? [String] {
			link?.attributes.append(contentsOf: attributes)
		}
	}
	
	override open var cellClass: AnyClass? {
		return VideoListItemViewCell.self
	}
	
	override open func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		
		super.configure(cell: cell, at: indexPath, in: tableViewController)
		guard let videoCell = cell as? VideoListItemViewCell else { return }
		videoCell.duration = duration
		
		if let imageHeight = imageHeight(constrainedTo: tableViewController.view.frame.width) {
			videoCell.imageHeightConstraint.constant = imageHeight
		}
	}
}
