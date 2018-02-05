//
//  VideoLanguageViewController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 06/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

public protocol VideoLanguageSelectionViewControllerDelegate {
	func selectionViewController(viewController: VideoLanguageSelectionViewController, didSelect video: Video)
}

/// This view controller is presented by the video player when a user attempts to switch languages.
/// It will display a list of languages for which a video is available
open class VideoLanguageSelectionViewController: TableViewController {

	/// The delegate to be called when a new video is selected
	var videoSelectionDelegate: VideoLanguageSelectionViewControllerDelegate?
	
	private let videos: [Video]
	
	/// Initialises the language sector with the array of videos, usually passed from a video player
	///
	/// - Parameter videos: The array of videos to select from
	public init(videos: [Video]) {
		
		self.videos = videos
		super.init(style: .grouped)
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "done".localised(with: "_STORM_VIDEOLANGUAGE_NAVIGATION_DONE"), style: .plain, target: self, action: #selector(dismissAnimated))
	}
	
	required public init?(coder aDecoder: NSCoder) {
		videos = []
		super.init(coder: aDecoder)
	}
	
	override open func viewDidLoad() {
		
		super.viewDidLoad()
		
		let languageSelection = TableSection(rows: videos, header: "Languages".localised(with: "_STORM_VIDEOLANGUAGE_SECTIONHEADER"), footer: nil) { [weak self] (row, selected, indexPath, tableView) -> (Void) in
			
			guard let video = row as? Video else { return }
			guard let welf = self else { return }
			welf.videoSelectionDelegate?.selectionViewController(viewController: welf, didSelect: video)
		}
		
		data = [languageSelection]
	}
}
