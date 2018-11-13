//
//  LocalisationLocale.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 13/11/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

//{"strings":{"_ABANDONED_NOTIFICATION_BUTTON_FINISH":{"en":"Finish Scheduling."}}}

//{
//    "id": 9,
//    "language": {
//        "id": 1,
//        "code": {
//            "iso2": "en",
//            "iso3": "eng"
//        },
//        "name": {
//            "native": "English",
//            "translations": {
//                "eng": "English"
//            }
//        }
//    },
//    "country": {
//        "id": 226,
//        "code": {
//            "iso2": "US",
//            "iso3": "USA"
//        }
//    },
//    "code": "en",
//    "publishable": {
//        "test": true,
//        "live": true
//    }
//}

/// A representation of a locale in the CMS
public struct LocalisationLocale {
    
    /// A unique ID that represents the language in the CMS
    public var uniqueIdentifier: String?
    
    /// The short code that represents the language in the CMS
    public var languageCode: String = ""
    
    /// The localised language name for the given language, provided by the CMS
    public var languageName: String?
    
    /// Whether the language has been published in the CMS
    public var isPublishable: (test: Bool, live: Bool) = (test: false, live: false)
    
    /// Initialises a dictionary from a CMS representation of a language
    ///
    /// - Parameter dictionary: The dictionary representation
    public init(dictionary: [AnyHashable : Any]) {
        
        uniqueIdentifier = dictionary["id"] as? String
        languageCode = dictionary["code"] as? String ?? ""
        
        if let publishable = dictionary["publishable"] as? [AnyHashable : Bool],
            let live = publishable["live"],
            let test = publishable["test"] {
            isPublishable = (test, live)
        }
        
        guard let language = dictionary["language"] as? [AnyHashable : Any] else { return }
        guard let name = language["name"] as? [AnyHashable : Any] else { return }
        
        languageName = name["native"] as? String
    }
}
