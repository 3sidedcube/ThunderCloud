//
//  SpotlightImageListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// `LegacySpotlightImageListItem` is an override to `SpotlightImageListItem` which disables ADA
/// compliant design for spotlights
open class LegacySpotlightImageListItem: LegacySpotlightListItem {
    
    public required init(dictionary: [AnyHashable : Any]) {
        
        super.init(dictionary: dictionary)
        
        guard let imagesArray = dictionary["images"] as? [[AnyHashable : Any]] else { return }
        spotlights = imagesArray.map({ (imageDict) -> Spotlight in
            return Spotlight(dictionary: imageDict)
        })
    }
}


