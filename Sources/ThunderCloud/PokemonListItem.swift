//
//  PokemonListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// An item to be displayed in TSCPokemonListItemView
public class PokemonListItem: StormObject {
	
	/// The link to the app via url schemes
	public var localLink: URL?
	
	/// The link to the app on the app store
	public var appStoreLink: URL?
	
	/// The image for the app
	public var image: UIImage?
	
	/// The name of the app
	public var name: String?
	
	public var isInstalled: Bool {
		guard let localLink = localLink else {
			return false
		}
		return UIApplication.shared.canOpenURL(localLink)
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
