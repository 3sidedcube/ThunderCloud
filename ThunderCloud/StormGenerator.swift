//
//  TSCStormViewController.swift
//  ThunderCloud
//
//  Created by Matthew Cheetham on 02/02/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation

/// A block which is called when a native link is clicked in the App
///
/// - Param: name The native link name
/// - Param: navigationController The navigation controller which the link was pushed on
/// - Returns: A boolean as to whether the link was handled or not
public typealias NativeLinkHandler = (_ name: String, _ navigationController: UINavigationController) -> Bool

/// Generates view controllers from URL's, page ID's and names and returns an optional `UIViewController` so that it can be type checked against custom types.
///
/// Also generates images from their storm object representations
@objc(TSCStormGenerator)
public class StormGenerator: NSObject {
	
	@objc(sharedController)
	static let shared = StormGenerator()
	
	//MARK: - View Controllers -
	
	/// A block which can be registered to handle storm native links.
	///
	/// This can be used for example to catch links with specific names and show custom UI or perform custom actions
	var nativeLinkHandler: NativeLinkHandler?
	
	/// A dictionary of maps between native page names and either a UIViewController class or a dictionary representing where in a storyboard to instantiate it from
	@objc public var nativePageLookupDictionary: [AnyHashable : Any] = [:]
    
    /// Turns a storm page name (Internal system name) into a view controller
    ///
    /// - Parameter name: The internal system name for the page to generate
    /// - Returns: An optional `UIViewController` that may be a subclass of UIViewController. Most likely `TSCListPage`
    public class func viewController(name: String) -> UIViewController? {
        
        let pageMetaDataDictionary = ContentController.shared.metadataForPage(withName: name)
        
        if let _pageMetaDataDictionary = pageMetaDataDictionary, let pageSrc = _pageMetaDataDictionary["src"] as? String, let pageURL = URL(string: pageSrc) {
            return StormGenerator.viewController(URL: pageURL)
        }
        return nil
    }
	
	private static let StormNativePageStoryboardName = "storyboardName"
	
	private static let StormNativePageStoryboardIdentifier = "interfaceIdentifier"
	
	private static let StormNativePageStoryboardBundleIdentifier = "bundleId"
	
	/// Turns a storm page name (Internal system name) into a view controller
	///
	/// - Parameter name: The internal system name for the page to generate
	/// - Returns: An optional `UIViewController` that may be a subclass of UIViewController. Most likely `TSCListPage`
	public class func viewController(nativePageName: String) -> UIViewController? {
		
		guard let object = StormGenerator.shared.nativePageLookupDictionary[nativePageName] else {
			return nil
		}
		
		if let dictionary = object as? [AnyHashable : Any], let storyboardName = dictionary[StormNativePageStoryboardName] as? String, let identifier = dictionary[StormNativePageStoryboardIdentifier]  as? String {
			
			var bundle: Bundle = .main
			if let bundleId = dictionary[StormNativePageStoryboardBundleIdentifier] as? String {
				bundle = Bundle(identifier: bundleId) ?? .main
			}
			
			let storyboard = UIStoryboard(name: storyboardName, bundle: bundle)
			return storyboard.instantiateViewController(withIdentifier: identifier)
			
		} else if let nativePageClassName = object as? String, let vCClass = NSClassFromString(nativePageClassName) as? UIViewController.Type {
			return vCClass.init(nibName: nil, bundle: nil)
		}
		
		return nil
	}
    
    /// Turns a storm page ID into a view controller
    ///
    /// - Parameter identifier: The storm page ID to convert into a view controller
    /// - Returns: An optional `UIViewController` that may be a subclass of UIViewController. Most likely `TSCListPage`
    public class func viewController(identifier: String) -> UIViewController? {
        
        let cacheURL = URL(string: "cache://pages/\(identifier).json")
        
        if let _cacheURL = cacheURL {
            return StormGenerator.viewController(URL: _cacheURL)
        }
        return nil
    }
    
    /// Takes a cache URL and converts it into a view controller
    ///
    /// - Parameter URL: The cache URL to convert (e.g. "cache://pages/123.json")
    /// - Returns: An optional `UIViewController` that may be a subclass of UIViewController. Most likely `TSCListPage`
    @objc public class func viewController(URL: URL) -> UIViewController? {
        
        guard let type = URL.host else {
            return nil
        }
		
		switch type {
		case "pages":
			
			guard let pageURL = ContentController.shared.url(forCacheURL: URL) else {
				return nil
			}
			
			guard let pageData = try? Data(contentsOf: pageURL), let jsonObject = (try? JSONSerialization.jsonObject(with: pageData, options: [])) as? [AnyHashable: Any] else {
				return nil
			}
			
			return StormObjectFactory.shared.stormObject(with: jsonObject) as? UIViewController
			
		case "native":
			
			let nativePageName = URL.lastPathComponent
			return StormGenerator.viewController(nativePageName: nativePageName)
			
		default:
			return nil
		}
    }
	
	/// Registers a UIViewController class to a particular native page name
	///
	/// - Parameters:
	///   - viewControllerClass: The view controller to register with the native page
	///   - forNativePageName: The native page name to register
	public class func register(viewControllerClass: UIViewController.Type, forNativePageName: String) {
		StormGenerator.shared.nativePageLookupDictionary[forNativePageName] = NSStringFromClass(viewControllerClass)
	}
	
	/// Registers a view controller from a storyboard to a particular native page name
	///
	/// - Parameters:
	///   - withInterfaceIdentifier: The identifier used in interface builder for the view controller
	///   - inStoryboardName: The name of the storyboard the view controller is in
	///   - bundle: The bundle which the storyboard is in
	///	  - forNativePageName: The native page name to register the view controller to
	public class func registerViewController(withInterfaceIdentifier: String, inStoryboardNamed: String, in bundle: Bundle? = nil, forNativePageName: String) {
		
		var lookupDictionary = [
			StormNativePageStoryboardName: inStoryboardNamed,
			StormNativePageStoryboardIdentifier: withInterfaceIdentifier
		]
		
		if let bundle = bundle, let bundleId = bundle.bundleIdentifier {
			lookupDictionary[StormNativePageStoryboardBundleIdentifier] = bundleId
		}
		
		StormGenerator.shared.nativePageLookupDictionary[forNativePageName] = lookupDictionary
	}
	
	//MARK: - Images -
	
	/// Generates an image from a Storm image object structure
	///
	/// - Parameter fromJSON: A JSON Object (returned by JSONSerialization) to fetch an image for
	@objc public class func image(fromJSON: Any?) -> UIImage? {
		
		guard let json = fromJSON else { return nil }
		
		if let array = json as? [[AnyHashable : Any]] {
			return image(fromRepresentations: array)
		} else if let dictionary = json as? [AnyHashable : Any] {
			return image(fromDictionary: dictionary)
		}
		
		return nil
	}
	
	private static let allowedMimeTypes = [
		// Tagged Image File Format (TIFF)
		"image/tiff",
		"image/x-tiff",
		// Joint Photographic Experts Group (JPEG)
		"image/jpeg",
		"image/pjpeg",
		// Graphic Interchange Format (GIF)
		"image/gif",
		// Portable Network Graphic (PNG)
		"image/png",
		// Windows Bitmap Format (DIB)
		"image/bmp",
		"image/x-windows-bmp",
		// Windows Icon Format && Windows Cursor
		"image/x-icon",
		// X Window System bitmap
		"image/xbm",
		"image/x-xbm",
		"image/x-xbitmap"
	]
	
	/// Returns an image from array of CMS image representation objects
	///
	/// - Parameter representationArray: An array of image representation
	/// - Returns: An image if one could be found
	private class func image(fromRepresentations representationArray: [[AnyHashable : Any]]) -> UIImage? {
		
		let allAvailableRepresentations = representationArray.flatMap { (representation) -> ImageRepresentation? in
			return ImageRepresentation(dictionary: representation)
		}
		
		let validRepresentations = allAvailableRepresentations.filter { (imageRepresentation) -> Bool in
			
			guard let mimeType = imageRepresentation.mimeType, let locale = imageRepresentation.locale else {
				return false
			}
			
			return allowedMimeTypes.contains(mimeType.lowercased()) && locale == StormLanguageController.shared.currentLanguage
		}
		
		let screenScale = UIScreen.main.scale
		
		if screenScale == 3.0, let imageRepresentation = validRepresentations.last, let imageURL = imageRepresentation.source.url {
			return image(at: imageURL, scale: screenScale)
		} else if screenScale == 1.0, let imageRepresentation = validRepresentations.first, let imageURL = imageRepresentation.source.url {
			return image(at: imageURL, scale: screenScale)
		}
		
		let middleValue = Int(ceil(Double(validRepresentations.count/2)))
		
		guard middleValue - 1 < validRepresentations.count, let imageURL = validRepresentations[middleValue - 1].source.url else {
			return nil
		}
		
		return image(at: imageURL, scale: screenScale)
	}
	
	/// Returns an image from the bundle at a specific URL and scale
	///
	/// - Parameters:
	///   - cacheURL: The URL to look for an image
	///   - scale: The scale the image will be displayed at (1x, 2x, 3x)
	/// - Returns: Either an image from the assets catalogue or an image read from the storm bundle on disk
	private class func image(at cacheURL: URL, scale: CGFloat) -> UIImage? {
		
		// Check XCAssets folder
		if let assetsImage = imageFromXCAssets(with: cacheURL) {
			return assetsImage
		}
		
		// Otherwise pull from bundle!
		guard let imageFileURL = ContentController.shared.url(forCacheURL: cacheURL) else { return nil }
		guard let imageData = try? Data(contentsOf: imageFileURL) else { return nil }
		
		return UIImage(data: imageData, scale: scale)
	}
	
	private class func image(fromDictionary imageDictionary: [AnyHashable : Any]) -> UIImage? {
		
		// Old image style!
		if let imageClass = imageDictionary["class"] as? String, imageClass == "NativeImage" {
			
			guard let src = imageDictionary["src"] as? String, let imageURL = URL(string: src) else {
				return nil
			}
			
			return UIImage(named: imageURL.lastPathComponent)

		} else if let sourceDictionary = imageDictionary["src"] as? [AnyHashable : String] {
			
			// Fall back to 2.0 on 3.0 screens because storm doesn't support 3x assets
			let scale = UIScreen.main.scale == 3.0 ? 2.0 : UIScreen.main.scale
			let scaleKey = "x\(Int(scale))"
			
			// Get the source for the correct scale from dictionary
			guard let scaleSource = sourceDictionary[scaleKey], let imageURL = URL(string: scaleSource) else {
				return nil
			}
			
			return image(at: imageURL, scale: scale)
		}
		
		return nil
	}
	
	/// Looks for a storm image in the XCAssets catalogue for the storm bundle
	///
	/// - Parameter imageURL: The url to look for an XCAsset for
	/// - Returns: An image if one could be found in the assets catalogue
	private class func imageFromXCAssets(with imageURL: URL) -> UIImage? {
		
		var thinnedAssetName = imageURL.lastPathComponent
		
		if let lastUnderscoreComponent = thinnedAssetName.components(separatedBy: "_").last, lastUnderscoreComponent != thinnedAssetName && (lastUnderscoreComponent.contains(".png") || lastUnderscoreComponent.contains(".jpg")) {
			thinnedAssetName = thinnedAssetName.replacingOccurrences(of: "_\(lastUnderscoreComponent)", with: "")
		}
		
		return UIImage(named: thinnedAssetName)
	}
}
