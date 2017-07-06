//
//  SpotlightImageListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// `TSCSpotlightImageListItem` is a model representation of a spotlight, it acts as a `TSCTableRowDataSource`
@available(*, deprecated, message: "Please use `SpotlightListItem` instead")
class SpotlightImageListItem: SpotlightListItem {

	required init(dictionary: [AnyHashable : Any], parentObject: StormObjectProtocol?) {
		
		super.init(dictionary: dictionary, parentObject: parentObject)
		
		guard let imagesArray = dictionary["images"] as? [[AnyHashable : Any]] else { return }
		spotlights = imagesArray.map({ (imageDict) -> Spotlight in
			return Spotlight(dictionary: imageDict, parentObject: self)
		})
	}
}


