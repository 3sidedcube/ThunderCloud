//
//  Localisation.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 06/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// A class representation of a CMS localisation object
public class Localisation {

	/// The localisation key that represents the string in the CMS (e.g. "_TEST_DONE_BUTTON_TEXT")
	public let localisationKey: String
	
	/// An array of `LocalisationKeyValue` objects that represent the value for each language for a given key
	public var localisationValues: [LocalisationKeyValue] = []
	
	/// Initializes a `Localisation` object from a CMS dictionary
	///
	/// - Parameter dictionary: The dictionary representing a localisation object
	public init?(dictionary: [AnyHashable : Any], key: String) {
		
		localisationKey = key
				
		dictionary.forEach({ (keyValue) in
			
			let localisationKeyValue = LocalisationKeyValue()
			localisationKeyValue.languageCode = keyValue.key as? String ?? ""
			localisationKeyValue.localisedString = keyValue.value as? String
			
			localisationValues.append(localisationKeyValue)
		})
	}
	
	/// Creates a new Localisation with no strings set for any language
	///
	/// - Parameter availableLanguages: An array of `LocalisationLanguage` objects
    public init(availableLanguageCodes: [String], key: String) {
		
		localisationKey = key
		        
		localisationValues = availableLanguageCodes.map({ (language) -> LocalisationKeyValue in
			
			let keyValue = LocalisationKeyValue()
			keyValue.languageCode = language
			
			return keyValue
		})
	}
	
	/// Sets the localised string for a particular language code
	///
	/// - Parameters:
	///   - localisedString: The localised string to be set
	///   - languageCode: The language code to set the string for
	public func set(localisedString: String, for languageCode: String) {
		
		let localisationValue = localisationValues.first { (keyValue) -> Bool in
			return keyValue.languageCode == languageCode
		}
		localisationValue?.localisedString = localisedString
	}
	
	public var serialisableRepresentation: [AnyHashable : Any] {
		var representation: [AnyHashable : Any] = [:]
		localisationValues.forEach { (keyValue) in
			
			guard let localisedString = keyValue.localisedString else { return }
			representation[keyValue.languageCode] = localisedString
		}
		return representation
	}
}
