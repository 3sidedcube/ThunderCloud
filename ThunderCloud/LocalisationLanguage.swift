//
//  LocalisationLanguage.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 06/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// A representation if a language in the CMS
@objc(TSCLocalisationLanguage)
public class LocalisationLanguage: NSObject {
	
	/// A unique ID that represents the language in the CMS
	public var uniqueIdentifier: String?
	
	/// The short code that represents the language in the CMS
	public var languageCode: String = ""
	
	/// The localised language name for the given language, provided by the CMS
	public var languageName: String?
	
	/// Whether the language has been published in the CMS
	public var isPublishable = false

	/// Initialises a dictionary from a CMS representation of a language
	///
	/// - Parameter dictionary: The dictionary representation
	public init(dictionary: [AnyHashable : Any]) {
		
		uniqueIdentifier = dictionary["id"] as? String
		languageCode = dictionary["code"] as? String ?? ""
		languageName = dictionary["name"] as? String
		
		if let publishable = dictionary["publishable"] as? Bool {
			isPublishable = publishable
		}
	}
}
