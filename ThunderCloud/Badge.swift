//
//  Badge.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 21/08/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// `Badge` is a model representation of a storm badge object
open class Badge: NSObject, StormObjectProtocol {
    
    /// A string of text that is displayed when the badge is unlocked
    public let completionText: String?
    
    /// A string of text which informs the user how to unlock the badge
    public let howToEarnText: String?
    
    /// The text that is used when the user shares the badge
    public let shareMessage: String?
    
    /// The title of the badge
    public let title: String?
    
    /// The unique identifier for the badge
    public let id: String?
    
    /// A `Dictionary` representation of the badge's icon, this can be converted to a `TSCImage` to return the `UIImage` representation of the icon
    private var iconObject: Any?
    
    /// The badge's icon, to be displayed in any badge scrollers e.t.c.
    open lazy var icon: UIImage? = { [unowned self] in
        return StormGenerator.image(fromJSON: iconObject)
        }()
    
    /// The accessibility label of the badge icon
    public var iconAccessibilityLabel: String? {
        guard let iconDict = iconObject as? [AnyHashable : Any], let accessibilityLabelDict = iconDict["accessibilityLabel"] as? [AnyHashable : Any] else { return nil }
        return StormLanguageController.shared.string(for: accessibilityLabelDict)
    }
    
    required public init(dictionary: [AnyHashable : Any]) {
        
        if let completionTextDictionary = dictionary["completion"] as? [AnyHashable : Any] {
            completionText = StormLanguageController.shared.string(for: completionTextDictionary)
        } else {
            completionText = nil
        }
        
        if let howToEarnTextDictionary = dictionary["how"] as? [AnyHashable : Any] {
            howToEarnText = StormLanguageController.shared.string(for: howToEarnTextDictionary)
        } else {
            howToEarnText = nil
        }
        
        if let shareMessageDictionary = dictionary["shareMessage"] as? [AnyHashable : Any] {
            shareMessage = StormLanguageController.shared.string(for: shareMessageDictionary)
        } else {
            shareMessage = nil
        }
        
        if let titleDictionary = dictionary["title"] as? [AnyHashable : Any] {
            title = StormLanguageController.shared.string(for: titleDictionary)
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
        
        iconObject = dictionary["icon"]
        
        super.init()
    }
}
