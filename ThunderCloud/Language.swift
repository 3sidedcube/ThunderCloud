//
//  Language.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 13/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// An object representation og a storm language
///
/// This conforms to `Row` and `NSCoding` and so can easily be displayed in a table view (will just display the localised language name) and encoded for storing in `NSUserDefaults`
@objc (TSCLanguage) // This is required so we can still migrate from old `TSCLanguage` objects (Otherwise NSKeyedUnarchiver will crash)
public class Language: NSObject, StormObjectProtocol, NSCoding {
	
	override public init() {
		
	}

	/// The localised name for the language
	@objc public var localisedLanguageName: String?
	
	/// The unique identifier for the language
	@objc public var languageIdentifier: String?
	
	required public init(dictionary: [AnyHashable : Any]) {
		
		super.init()
		
		localisedLanguageName = dictionary["localisedLanguageName"] as? String
		languageIdentifier = dictionary["languageIdentifier"] as? String
	}
	
	public required convenience init?(coder aDecoder: NSCoder) {
		
		self.init(dictionary: [:])
		localisedLanguageName = aDecoder.decodeObject(forKey: "TSCLanguageName") as? String
		languageIdentifier = aDecoder.decodeObject(forKey: "TSCLanguageIdentifier") as? String
	}
	
	public func encode(with aCoder: NSCoder) {
		
		aCoder.encode(localisedLanguageName, forKey: "TSCLanguageName")
		aCoder.encode(languageIdentifier, forKey: "TSCLanguageIdentifier")
	}
}

extension Language: Row {
	
	public var title: String? {
		return localisedLanguageName
	}
	
	public var accessoryType: UITableViewCellAccessoryType? {
		
        guard let currentLanguage = StormLanguageController.shared.currentLanguage, let languageId = languageIdentifier else { return UITableViewCellAccessoryType.none
        }
        
        if let overrideLanguageId = StormLanguageController.shared.overrideLanguagePack?.locale.identifier, overrideLanguageId == languageId {
            return .checkmark
        } else if languageId == currentLanguage {
            return .checkmark
        }
        
        return UITableViewCellAccessoryType.none
	}
}
