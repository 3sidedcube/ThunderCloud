//
//  AppLinkController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 02/11/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation

/// App link controller is a controller for linking between different apps on the user's phone.
///
/// It creates an array of AppIdentity structs out of the content controller when first initialised.
public struct AppLinkController {
	
	var apps: [AppIdentity] = []
	
	public init() {
		
		// Load up identities JSON
		guard let identityURL = ContentController.shared.fileUrl(forResource: "identifiers", withExtension: "json", inDirectory: "data") else {
			return
		}
		
		guard let identityData = try? Data(contentsOf: identityURL) else {
			return
		}
		
		guard let identitiesDictionary = (try? JSONSerialization.jsonObject(with: identityData, options: [])) as? [AnyHashable : [String : Any]] else {
			return
		}
		
		apps = identitiesDictionary.compactMap({ (keyValue) -> AppIdentity? in
			
			var dictionary = keyValue.value
			dictionary["appIdentifier"] = keyValue.key
			return AppIdentity(dictionary: dictionary)
		})
	}
}
