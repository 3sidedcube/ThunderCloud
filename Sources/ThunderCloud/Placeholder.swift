//
//  Placeholder.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 02/11/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// A representation of a `UITabBarItem` for usage in `AccordionTabBarViewController`
struct Placeholder {
    
    /// Initializes a new placeholder with a dictionary
    ///
    /// - Parameter dictionary: Dictionary representation of the placeholder
    init(dictionary: [AnyHashable : Any]) {
        
        if let titleDictionary = dictionary["title"] as? [AnyHashable : Any] {
            title = StormLanguageController.shared.string(for: titleDictionary)
        } else {
            title = nil
        }
        
        if let descriptionDictionary = dictionary["description"] as? [AnyHashable : Any] {
            description = StormLanguageController.shared.string(for: descriptionDictionary)
        } else {
            description = nil
        }
        
        image = StormGenerator.image(fromJSON: dictionary["placeholderImage"])
    }
    
    /// The tab's title
    let title: String?
    
    /// The tab's description
    let description: String?
    
    /// The tab icon image
    let image: StormImage?
}
