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
open class Spotlight: StormObject {
	
	/// A `UIImage` that is displayed for the spotlight
	open var image: UIImage?
	
	/// A `TSCLink` that is used to perform an action when an item is selected
	open var link: TSCLink?
	
	/// How long the item should be displayed on screen for
	open var delay: TimeInterval?
	
	/// A string of text which is displayed across the center of the spotlight item
	open var spotlightText: String?

	required public init(dictionary: [AnyHashable : Any]) {
		
		super.init(dictionary: dictionary)
		
		if let imageDict = dictionary["image"] as? NSObject {
			image = TSCImage.image(withJSONObject: imageDict)
		}
		
		//This is for legacy spotlight image support
		if image == nil {
			image = TSCImage.image(withJSONObject: dictionary as NSObject)
		}
		
		delay = dictionary["delay"] as? TimeInterval
		if let delay = delay {
			self.delay = delay / 1000
		}
		
		if let spotlightTextDictionary = dictionary["text"] as? [AnyHashable : Any] {
			spotlightText = StormLanguageController.shared.string(for: spotlightTextDictionary)
		}
		
		if let linkDictionary = dictionary["link"] as? [AnyHashable : Any], linkDictionary["destination"] != nil {
			link = TSCLink(dictionary: linkDictionary)
		}
	}
}
