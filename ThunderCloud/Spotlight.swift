//
//  Spotlight.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// A model representation of a spotlight that will be displayed inside a view.
/// This object will usually be part of an array which is cycled through when displayed
class Spotlight: StormObject {
	
	/// A `UIImage` that is displayed for the spotlight
	var image: UIImage?
	
	/// A `TSCLink` that is used to perform an action when an item is selected
	var link: TSCLink?
	
	/// How long the item should be displayed on screen for
	var delay: TimeInterval?
	
	/// A string of text which is displayed across the center of the spotlight item
	var spotlightText: String?

	required init(dictionary: [AnyHashable : Any], parentObject: StormObjectProtocol?) {
		super.init(dictionary: dictionary, parentObject: parentObject)
		
		// Legacy spotlight image support
		if let imageDict = dictionary["image"] as? NSObject {
			image = TSCImage.image(withJSONObject: imageDict)
		}
		
		delay = dictionary["delay"] as? TimeInterval
		
		if let spotlightTextDictionary = dictionary["text"] as? [AnyHashable : Any] {
			spotlightText = TSCLanguageController.shared().string(for: spotlightTextDictionary)
		}
		
		if let linkDictionary = dictionary["link"] as? [AnyHashable : Any], linkDictionary["destination"] != nil {
			link = TSCLink(dictionary: linkDictionary)
		}
	}
}