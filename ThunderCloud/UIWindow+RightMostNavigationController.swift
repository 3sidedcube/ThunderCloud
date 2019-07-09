//
//  UIWindow+RightMostNavigationController.swift
//  ThunderCloud
//
//  Created by Ryan Bourne on 09/07/2019.
//  Copyright © 2019 3 SIDED CUBE. All rights reserved.
//

import Foundation

extension UIWindow {
    
    /// Attempts to fetch the right-most UINavigationController from the window's rootViewController.
    ///
    /// We do this, as to provide a consistent way of:
    ///     - Retrieving the 'detail' part of a UISplitViewController on iPad.
    ///     - Retrieving the standard navigation controller on iPhone.
    ///
    /// If it doesn't exist, or the rootViewController's final child is not a UINavigationController, this will be nil.
    var rightMostNavigationController: UINavigationController? {
        return self.rootViewController?.children.last as? UINavigationController
    }
}

