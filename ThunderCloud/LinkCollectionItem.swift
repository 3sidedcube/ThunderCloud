//
//  LinkCollectionItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 02/11/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation

/// A model representation of a link to be shown in a `TSCAppScrollerItemViewCell`
open class LinkCollectionItem: StormObjectProtocol {
    
    /// The link of the link item
    let link: StormLink?
    
    /// The image to be displayed for the link
    let image: UIImage?
    
    /// The accessibility label of the image for the link
    let imageAccessibilityLabel: String?
    
    /**
     Initializes a new instance of `TSCLinkCollectionItem` from a CMS representation
     @param dictionary The dictionary to initialize and populate the link from
     */
    public required init?(dictionary: [AnyHashable : Any]) {
        
        image = StormGenerator.image(fromJSON:  dictionary["image"])
        if let imageDict = dictionary["image"] as? [AnyHashable : Any], let accessibilityLabelDictionary = imageDict["accessibilityLabel"] as? [AnyHashable : Any] {
            imageAccessibilityLabel = StormLanguageController.shared.string(for: accessibilityLabelDictionary)
        } else {
            imageAccessibilityLabel = nil
        }
        
        if let linkDictionary = dictionary["link"] as? [AnyHashable : Any] {
            link = StormLink(dictionary: linkDictionary)
        } else {
            link = nil
        }
    }
}
