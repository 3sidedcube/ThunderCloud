//
//  PokemonListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// An item to be displayed in TSCPokemonListItemView
class PokemonListItem: StormObject {
	
	/// The link to the app via url schemes
	var localLink: URL?
	
	/// The link to the app on the app store
	var appStoreLink: URL?
	
	/// The image for the app
	var image: UIImage?
	
	/// The name of the app
	var name: String?
	
	var isInstalled: Bool {
		guard let _localLink = localLink else {
			return false
		}
		return UIApplication.shared.canOpenURL(_localLink)
	}

	required init(dictionary: [AnyHashable : Any]) {
		
		super.init(dictionary: dictionary)
		
		if let localLinkString = dictionary["localLink"] as? String {
			localLink = URL(string: localLinkString)
		}
		
		if let appStoreLinkString = dictionary["appStoreLink"] as? String {
			appStoreLink = URL(string: appStoreLinkString)
		}
		
		image = dictionary["image"] as? UIImage
		name = dictionary["name"] as? String		
	}
}
