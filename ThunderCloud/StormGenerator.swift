//
//  TSCStormViewController.swift
//  ThunderCloud
//
//  Created by Matthew Cheetham on 02/02/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation

/// A Swift replacement for TSCStormViewController. Generates view controllers from URL's, page ID's and names and returns an optional `UIViewController` so that it can be type checked against custom types.

/**
A block which is called when a native link is clicked in the App

@param name The native link name
@param navigationController The view navigation controller which the link was pushed on
@return A boolean as to whether the block has handled the link or not
*/
public typealias NativeLinkHandler = (_ name: String, _ navigationController: UINavigationController) -> Bool


@objc(TSCStormGenerator)
public class StormGenerator: NSObject {
	
	@objc(sharedController)
	static let shared = StormGenerator()
	
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
}
