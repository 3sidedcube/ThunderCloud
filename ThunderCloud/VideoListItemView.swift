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
	
	required init(dictionary: [AnyHashable : Any], parentObject: StormObjectProtocol?) {
		super.init(dictionary: dictionary, parentObject: parentObject)
		
		// Duration is done in milliseconds due to Android
		if let _duration = dictionary["duration"] as? TimeInterval {
			duration = _duration/1000
		}
		
		if let _attributes = dictionary["attributes"] as? [Any] {
			link?.attributes?.addObjects(from: _attributes)
		}
	}
	
	override var cellClass: AnyClass? {
		return VideoListItemViewCell.self
	}
	
	override func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		
		super.configure(cell: cell, at: indexPath, in: tableViewController)
		guard let videoCell = cell as? VideoListItemViewCell else { return }
		videoCell.duration = duration
	}
}
