//
//  VideoListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 07/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// A storm object representation of a video view
open class VideoListItem: VideoListItemView {

	/// The array of videos that are available to be played when this item is clicked
	public var videos: [Video]?
	
	required public init(dictionary: [AnyHashable : Any]) {
		
		super.init(dictionary: dictionary)
		
		guard let videosArray = dictionary["videos"] as? [[AnyHashable : Any]] else { return }
		videos = videosArray.map({ (videoDictionary) -> Video in
			return Video(dictionary: videoDictionary)
		})
	}
	
	override open var cellClass: AnyClass? {
		return MultiVideoListItemCell.self
	}
	
	override open func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		
		super.configure(cell: cell, at: indexPath, in: tableViewController)
		parentNavigationController = tableViewController.navigationController
	}
	
	override open func handleSelection(of row: Row, at indexPath: IndexPath, in tableView: UITableView) {
		
		guard let videoRow = row as? VideoListItem, let videos = videoRow.videos else { return }
		videoRow.parentNavigationController?.pushVideos(videos)
	}
}
