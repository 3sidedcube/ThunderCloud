//
//  VideoListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 07/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// A storm object representation of a video view
class VideoListItem: VideoListItemView {

	/// The array of videos that are available to be played when this item is clicked
	var videos: [Video]?
	
	required init(dictionary: [AnyHashable : Any], parentObject: StormObjectProtocol?) {
		super.init(dictionary: dictionary, parentObject: parentObject)
		
		guard let videosArray = dictionary["videos"] as? [[AnyHashable : Any]] else { return }
		videos = videosArray.map({ (videoDictionary) -> Video in
			return Video(dictionary: videoDictionary)
		})
	}
	
	override var cellClass: AnyClass? {
		return MultiVideoListItemCell.self
	}
	
	override func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		
		super.configure(cell: cell, at: indexPath, in: tableViewController)
		parentNavigationController = tableViewController.navigationController
	}
	
	override func handleSelection(of row: Row, at indexPath: IndexPath, in tableView: UITableView) {
		
		guard let videoRow = row as? VideoListItem, let videos = videoRow.videos else { return }
		videoRow.parentNavigationController?.pushVideos(videos)
	}
}
