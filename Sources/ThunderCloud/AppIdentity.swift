//
//  AppIdentity.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 02/11/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation

open class AppIdentity: StormObjectProtocol {
	
	/// The unique identifier for the app identity
	public let identifier: String?
	
	/// The iTunes identifier for the app identity
	public let iTunesId: String?
	
	/// The iTunes country code for the app identity
	public let countryCode: String?
	
	/// The launcher url for the app
	/// This can be used to check if the app exists on the phone, and then be used to link the user to it
	public let launchURL: URL?
	
	/// The app's name
	public let name: String?
	
	public required init(dictionary: [AnyHashable : Any]) {
		
		identifier = dictionary["appIdentifier"] as? String
		
		if let iOSDictionary = dictionary["ios"] as? [AnyHashable : Any] {
			
			iTunesId = iOSDictionary["iTunesId"] as? String
			countryCode = iOSDictionary["countryCode"] as? String
			
			if let launchString = iOSDictionary["launcher"] as? String {
				launchURL = URL(string: launchString)
			} else {
				launchURL = nil
			}
			
		} else {
			
			iTunesId = nil
			countryCode = nil
			launchURL = nil
		}
		
		if let nameDictionary = dictionary["name"] as? [AnyHashable : Any], let languageKey = StormLanguageController.shared.currentLanguageShortKey {
			
			name = nameDictionary[languageKey] as? String ?? nameDictionary["en"] as? String
			
		} else {
			
			name = nil
		}
	}
	
	
}
