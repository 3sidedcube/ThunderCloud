//
//  Badge.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 21/08/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation

/// `Badge` is a model representation of a storm badge object
@objc(TSCBadge)
open class Badge: NSObject, StormObjectProtocol {
	
	/// A string of text that is displayed when the badge is unlocked
	open let completionText: String?
	
	/// A string of text which informs the user how to unlock the badge
	open let howToEarnText: String?
	
	/// The text that is used when the user shares the badge
	@objc open let shareMessage: String?
	
	/// The title of the badge
	@objc open let title: String?
	
	/// The unique identifier for the badge
	open let id: String?
	
	/// A `Dictionary` representation of the badge's icon, this can be converted to a `TSCImage` to return the `UIImage` representation of the icon
	private var iconObject: NSObject?
	
	/// The badge's icon, to be displayed in any badge scrollers e.t.c.
	@objc open lazy var icon: UIImage? = { [unowned self] in
		guard let iconOject = self.iconObject else { return nil }
		return TSCImage.image(withJSONObject: iconOject)
	}()
	
	required public init(dictionary: [AnyHashable : Any]) {
		
		if let completionTextDictionary = dictionary["completion"] as? [AnyHashable : Any] {
			completionText = TSCLanguageController.shared().string(for: completionTextDictionary)
		} else {
			completionText = nil
		}
		
		if let howToEarnTextDictionary = dictionary["how"] as? [AnyHashable : Any] {
			howToEarnText = TSCLanguageController.shared().string(for: howToEarnTextDictionary)
		} else {
			howToEarnText = nil
		}
		
		if let shareMessageDictionary = dictionary["shareMessage"] as? [AnyHashable : Any] {
			shareMessage = TSCLanguageController.shared().string(for: shareMessageDictionary)
		} else {
			shareMessage = nil
		}
		
		if let titleDictionary = dictionary["title"] as? [AnyHashable : Any] {
			title = TSCLanguageController.shared().string(for: titleDictionary)
		} else {
			title = nil
		}
		
		if let intId = dictionary["id"] as? Int {
			id = "\(intId)"
		} else if let stringId = dictionary["id"] as? String {
			id = stringId
		} else {
			id = nil
		}
		
		iconObject = dictionary["icon"] as? NSObject
		
		super.init()
	}
}
