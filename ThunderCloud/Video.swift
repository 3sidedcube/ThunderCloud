//
//  Video.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 06/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// A video object containing info about a video that can be played by the multi video player
public struct Video {
	
	/// The string representation of the locale that the video is in
	public var videoLocaleString: String?
	
	/// The locale of the video
	public var videoLocale: Locale? {
		guard let _localeKey = videoLocaleString else { return nil }
		return TSCStormLanguageController.shared().locale(forLanguageKey: _localeKey)
	}
	
	/// The link to the video file or relevant YouTube link
	public var videoLink: TSCLink?
	
	/// Initialises the video object with a dictionary of info provided by storm
	///
	/// - Parameter dictionary: A storm dictionary object of a video
	public init(dictionary: [AnyHashable : Any]) {
		
		videoLocaleString = dictionary["locale"] as? String
		
		if let source = dictionary["src"] as? [AnyHashable : Any] {
			videoLink = TSCLink(dictionary: source)
		}
	}
}

extension Video: Row {
	
	public var title: String? {
		guard let _localeKey = videoLocaleString else { return nil }
		return TSCStormLanguageController.shared().localisedLanguageName(forLocaleIdentifier: _localeKey)
	}
}
