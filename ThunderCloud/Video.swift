//
//  Video.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 06/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// A video object containing info about a video that can be played by the multi video player
public class Video: NSObject {
    
    /// Defines the video formats that are supported within Storm apps.
    /// While the MIME type of video/mp4 is checked when uploading, m4v videos can also have this MIME type.
    internal static let supportedVideoFormats: [String] = ["mp4", "m4v"]
	
	/// The string representation of the locale that the video is in
	public var localeString: String?
	
	/// The locale of the video
	public var locale: Locale? {
		guard let localeString = localeString else { return nil }
		return StormLanguageController.shared.locale(for: localeString)
	}
	
	/// The link to the video file or relevant YouTube link
	public var link: StormLink?
	
	/// Initialises the video object with a dictionary of info provided by storm
	///
	/// - Parameter dictionary: A storm dictionary object of a video
	public init(dictionary: [AnyHashable : Any]) {
		
		localeString = dictionary["locale"] as? String
		
		if let source = dictionary["src"] as? [AnyHashable : Any] {
			link = StormLink(dictionary: source)
		}
	}
}

extension Video: Row {
	
	public var title: String? {
        
		guard let localeString = localeString else { return nil }
        // Can't just send localeString in because it's the wrong format for `Locale`
        guard let languagePack = StormLanguageController.shared.languagePack(forLocaleIdentifier: localeString) else { return nil }
        return StormLanguageController.shared.localisedLanguageName(for: languagePack.locale)
	}
}
