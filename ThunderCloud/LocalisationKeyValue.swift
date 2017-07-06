//
//  LocalisationKeyValue.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 06/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

@objc(TSCLocalisationKeyValue)
///  An object representation of the value of a localised string for a particular language code
public class LocalisationKeyValue: NSObject {
	
	/// The language of this key and value
	public var language: LocalisationLanguage?
	
	/// The localised string for the associated language code
	public var localisedString: String?
	
	/// The short code that represents the language in the CMS (e.g. "en")
	public var languageCode: String = ""
}
