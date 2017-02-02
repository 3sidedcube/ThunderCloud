//
//  TSCStormViewController.swift
//  ThunderCloud
//
//  Created by Matthew Cheetham on 02/02/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation

/// A Swift replacement for TSCStormViewController. Generates view controllers from URL's, page ID's and names and returns an optional `UIViewController` so that it can be type checked against custom types.
public class StormGenerator {
    
    /// Turns a storm page ID into a view controller
    ///
    /// - Parameter identifier: The storm page ID to convert into a view controller
    /// - Returns: An optional `UIViewController` that may be a subclass of UIViewController. Most likely `TSCListPage`
    public class func viewController(with identifier: String) -> UIViewController? {
        
        let cacheURL = URL(string: "cache://pages/\(identifier).json")
        
        if let _cacheURL = cacheURL {
            return StormGenerator.viewController(with: _cacheURL)
        }
        return nil
    }
    
    /// Takes a cache URL and converts it into a view controller
    ///
    /// - Parameter URL: The cache URL to convert (e.g. "cache://pages/123.json")
    /// - Returns: An optional `UIViewController` that may be a subclass of UIViewController. Most likely `TSCListPage`
    public class func viewController(with URL: URL) -> UIViewController? {
        
        guard let type = URL.host else {
            return nil
        }
        
        if type == "pages" {
            
            guard let pageURL = ContentController.shared.url(forCacheURL: URL) else {
                return nil
            }
            
            guard let pageData = try? Data(contentsOf: pageURL), let jsonObject = try? JSONSerialization.jsonObject(with: pageData, options: []) as? [AnyHashable: Any] else {
                return nil
            }
            
            return TSCStormObject.object(with: jsonObject, parentObject: nil) as? UIViewController
        }
        
        return nil
    }
}
