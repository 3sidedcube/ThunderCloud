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
public struct Spotlight: StormObjectProtocol {
    
    /// A `StormImage` that is displayed for the spotlight
    public var image: StormImage?
    
    /// A `StormLink` that is used to perform an action when an item is selected
    public var link: StormLink?
    
    /// How long the item should be displayed on screen for
    public var delay: TimeInterval?
    
    /// A legacy string which is used for the title of the spotlight
    public var text: String?
    
    /// A string of text which is displayed as the title on the spotlight
    public var title: String?
    
    /// A string of text which defines the category of the spotlight
    public var category: String?
    
    /// A string of text which describes the spotlight in more detail
    public var description: String?
    
    public init(dictionary: [AnyHashable : Any]) {
                
        image = StormGenerator.image(fromJSON: dictionary["image"])
        
        //This is for legacy spotlight image support
        if image == nil {
            image = StormGenerator.image(fromJSON: dictionary)
        }
        
        delay = dictionary["delay"] as? TimeInterval
        if let delay = delay {
            self.delay = delay / 1000
        }
        
        if let textDictionary = dictionary["text"] as? [AnyHashable : Any] {
            text = StormLanguageController.shared.string(for: textDictionary)
        }
        
        if let titleDictionary = dictionary["title"] as? [AnyHashable : Any] {
            title = StormLanguageController.shared.string(for: titleDictionary)
        }
        
        if let categoryDictionary = dictionary["category"] as? [AnyHashable : Any] {
            category = StormLanguageController.shared.string(for: categoryDictionary)
        }
        
        if let descriptionDictionary = dictionary["description"] as? [AnyHashable : Any] {
            description = StormLanguageController.shared.string(for: descriptionDictionary)
        }
        
        if let linkDictionary = dictionary["link"] as? [AnyHashable : Any], linkDictionary["destination"] != nil {
            link = StormLink(dictionary: linkDictionary)
        }
    }
}
