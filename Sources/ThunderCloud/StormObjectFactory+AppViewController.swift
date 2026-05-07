//
//  StormObjectFactory+AppViewController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 12/10/2020.
//  Copyright © 2020 threesidedcube. All rights reserved.
//

import Foundation

extension StormObjectFactory {
    
    /// Creates an instance of `AppViewController` (or any subclass thereof) taking into account storm overrides
    /// - Returns: The view controller that was created
    static func createAppViewController() -> AppViewController {
        
        let appViewControllerClass: AppViewController.Type = StormObjectFactory.shared.class(
            for: String(describing: AppViewController.self)
        ) as? AppViewController.Type ?? AppViewController.self
        let appViewController = appViewControllerClass.init()
        
        return appViewController
    }
}
