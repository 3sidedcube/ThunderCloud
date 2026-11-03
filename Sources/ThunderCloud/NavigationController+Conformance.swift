//
//  NavigationController+Conformance.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 26/02/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import UIKit
import SafariServices
import MessageUI
import StoreKit
import ThunderTable

extension UINavigationController: SFSafariViewControllerDelegate {
    
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        // Notify we will dismiss a system `UIViewController`
        NotificationCenter.default.post(sender: self, present: false, systemViewController: controller)
        
        controller.dismissAnimated()
    }
}

extension UINavigationController: MFMessageComposeViewControllerDelegate {
    public func messageComposeViewController(
        _ controller: MFMessageComposeViewController,
        didFinishWith result: MessageComposeResult
    ){
        // Notify we will dismiss a system `UIViewController`
        NotificationCenter.default.post(sender: self, present: false, systemViewController: controller)
        
        // Rollback appearance changes made before presenting
        UIBarButtonItem.appearance().setTitleTextAttributes([
            .foregroundColor : ThemeManager.shared.theme.navigationBarTintColor
        ], for: .normal)
        
        // Dismiss the view controller
        controller.dismissAnimated()
    }
}

extension UINavigationController: SKStoreProductViewControllerDelegate {
    
    public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        // Notify we will dismiss a system `UIViewController`
        NotificationCenter.default.post(sender: self, present: false, systemViewController: viewController)
        
        UINavigationBar.appearance().tintColor = ThemeManager.shared.theme.navigationBarTintColor
        viewController.dismissAnimated()
    }
}
