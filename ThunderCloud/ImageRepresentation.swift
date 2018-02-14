//
//  ImageRepresentation.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 06/11/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation

/// An object representation of an image. This class is used to represent one image in an array of possible images that the app can use. The image representation will be used in a lookup after determining the devices screen density
struct ImageRepresentation {
	
	/// A link to the image in the bundle
	let source: StormLink
	
	/// The dimensions of the image
	let dimensions: CGSize
	
	/// The mime type of the image, can be used to check if the image is compatible with the device
	let mimeType: String?
	
	/// The bite size of the file
	let byteSize: Int?
	
	/// The storm locale of the image. Images may be localised in the future.
	let locale: String?
	
	init?(dictionary: [AnyHashable : Any]) {
		
		guard let srcDictionary = dictionary["src"] as? [AnyHashable : Any], let link = StormLink(dictionary: srcDictionary) else {
			return nil
		}
		
		source = link
		
		if let dimensionsDict = dictionary["dimensions"] as? [AnyHashable : CGFloat] {
			dimensions = CGSize(width: dimensionsDict["width"] ?? 0, height: dimensionsDict["height"] ?? 0)
		} else {
			dimensions = .zero
		}
		
		mimeType = dictionary["mime"] as? String
		byteSize = dictionary["size"] as? Int
		locale = dictionary["locale"] as? String
	}
}
