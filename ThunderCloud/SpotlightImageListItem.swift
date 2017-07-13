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
open class SpotlightImageListItem: SpotlightListItem {

	public required init(dictionary: [AnyHashable : Any]) {
		
		super.init(dictionary: dictionary)
		
		guard let imagesArray = dictionary["images"] as? [[AnyHashable : Any]] else { return }
		spotlights = imagesArray.map({ (imageDict) -> Spotlight in
			return Spotlight(dictionary: imageDict)
		})
	}
}


