//
//  AppViewController.swift
//  ThunderCloud
//
//  Created by Matthew Cheetham on 01/02/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation

/**
 `TSCAppViewController` is the root class of any Storm CMS driven app. By initialising this class, Storm builds the entire app defined by the JSON files included in the bundle delivered by Storm.
 
 Allocate an instance of this class and set it to the root view controller of the `UIWindow`.
 
 */
@objc(TSCAppViewController)
public class AppViewController: UISplitViewController {
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        
        StormLanguageController.shared.reloadLanguagePack()
        
        let appFileURL = ContentController.shared.fileUrl(forResource: "app", withExtension: "json", inDirectory: nil)
        
        if let _appFileURL = appFileURL {
            
            let appJSONObject = try? JSONSerialization.jsonObject(withFile:_appFileURL.path, options: [])
            
            if let _appJSONObject = appJSONObject as? [String: AnyObject], let vectorPath = _appJSONObject["vector"] as? String, let vectorURL = URL(string: vectorPath) {
                
                guard let stormView = TSCStormViewController(url: vectorURL) else {
                    return
                }
                
                let stormNavClass = TSCStormObject.class(forClassKey: "UINavigationController")
                
                if let _class = stormNavClass as? UINavigationController.Type {
                    let stormNavigationController = _class.init(rootViewController: stormView)
                    viewControllers = [stormNavigationController]
                }
                
//                let stormNavigationController = UINavigationController(rootViewController: stormView)
//                viewControllers = [stormNavigationController]
            }
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
