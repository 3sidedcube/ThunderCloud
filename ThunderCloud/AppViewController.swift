//
//  AppViewController.swift
//  ThunderCloud
//
//  Created by Matthew Cheetham on 01/02/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// AppViewController` is the root class of any Storm CMS driven app. By initialising this class, Storm builds the entire app defined by the JSON files included in the bundle delivered by Storm.
///
/// Allocate an instance of this class and set it to the root view controller of the `UIWindow`.
open class AppViewController: SplitViewController {
    
    open override var childForStatusBarStyle: UIViewController? {
        return viewControllers.first
    }
    
    public required init() {
		
        super.init()
        
        preferredDisplayMode = .oneBesideSecondary
        
        StormLanguageController.shared.reloadLanguagePack()
        
        let appFileURL = ContentController.shared.fileUrl(forResource: "app", withExtension: "json", inDirectory: nil)
        
        if let _appFileURL = appFileURL {
            
            let appJSONObject = try? JSONSerialization.jsonObject(with: _appFileURL)
            
            if let _appJSONObject = appJSONObject as? [String: AnyObject], let vectorPath = _appJSONObject["vector"] as? String, let vectorURL = URL(string: vectorPath) {
				
				guard let stormView = StormGenerator.viewController(URL: vectorURL) else {
                    return
                }
				
				var launchViewControllers: [UIViewController] = []
				
				// The accordion storm view needs to be wrapped in a UINavigationController otherwise no navigation works from within it!
				if let accordionStormView = stormView as? AccordionTabBarViewController {
					launchViewControllers.append(UINavigationController(rootViewController: accordionStormView))
				} else {
					launchViewControllers.append(stormView)
				}

				if UIDevice.current.userInterfaceIdiom == .pad, let tabbedPageCollection = stormView as? TabbedPageCollection, let placeholder = tabbedPageCollection.placeholders.first {
					
					let placeholderVC = PlaceholderViewController(placeholder: placeholder)
					launchViewControllers.append(placeholderVC)
				}
				
				viewControllers = launchViewControllers
            }
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
