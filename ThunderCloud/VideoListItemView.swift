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
class VideoListItemView: ImageListItem {

	/// The length of the video
	var duration: TimeInterval?
	
	required init(dictionary: [AnyHashable : Any]) {
		
		super.init(dictionary: dictionary)
		
		// Duration is done in milliseconds due to Android
		if let duration = dictionary["duration"] as? TimeInterval {
			self.duration = duration/1000
		}
		
		if let attributes = dictionary["attributes"] as? [Any] {
			link?.attributes?.addObjects(from: attributes)
		}
	}
	
	override var cellClass: AnyClass? {
		return VideoListItemViewCell.self
	}
	
	override func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		
		super.configure(cell: cell, at: indexPath, in: tableViewController)
		guard let videoCell = cell as? VideoListItemViewCell else { return }
		videoCell.duration = duration
		
		if let imageHeight = imageHeight(constrainedTo: tableViewController.view.frame.width) {
			videoCell.imageHeightConstraint.constant = imageHeight
		}
	}
}
