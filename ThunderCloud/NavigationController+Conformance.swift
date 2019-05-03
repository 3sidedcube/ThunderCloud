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
        controller.dismissAnimated()
    }
}

extension UINavigationController: MFMessageComposeViewControllerDelegate {
    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismissAnimated()
    }
}

extension UINavigationController: SKStoreProductViewControllerDelegate {
    
    public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        
        UINavigationBar.appearance().tintColor = ThemeManager.shared.theme.navigationBarTintColor
        viewController.dismissAnimated()
    }
}
