//
//  UIApplication+ViewController.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 12/12/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import UIKit

extension UIApplication {
    
    class var visibleViewController: UIViewController? {
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        return UIApplication.shared.visibleViewController(rootViewController)
    }
    
    func visibleViewController(_ viewController: UIViewController?) -> UIViewController? {
        if let navigationController = viewController as? UINavigationController {
            return visibleViewController(navigationController.visibleViewController)
        }
        if let tabController = viewController as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return visibleViewController(selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return visibleViewController(presented)
        }
        return viewController
    }
}
