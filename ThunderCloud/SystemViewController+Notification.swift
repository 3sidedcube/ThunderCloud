//
//  SystemViewController+Notification.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 09/03/2020.
//  Copyright © 2020 threesidedcube. All rights reserved.
//

import Foundation

// MARK: - Notification.Name

/// Key for user info when sending
public let systemViewControllerUserInfoKey = "com.3sidedcube.systemViewController"

extension Notification.Name {
    
    /// Called before `present(:animated:completion)` is called on a system view controller.
    /// E.g. `MFMessageComposeViewController`
    public static let willPresentSystemViewController =
        Notification.Name(rawValue: "com.3sidedcube.willPresentSystemViewController")
    
    /// Called before dismissing a system view controller.
    /// E.g. `MFMessageComposeViewController`
    public static let willDismissSystemViewController =
        Notification.Name(rawValue: "com.3sidedcube.willDismissSystemViewController")
}

extension Notification {
    
    /// `UIViewController` from `userInfo` of `self`
    public var systemViewController: UIViewController? {
        return userInfo?[systemViewControllerUserInfoKey] as? UIViewController
    }
}

extension NotificationCenter {
    
    func post(sender: Any, present: Bool, systemViewController: UIViewController) {
        let name: Notification.Name = present ?
            .willPresentSystemViewController :
            .willDismissSystemViewController
        
        post(
            name: name,
            object: sender,
            userInfo: [systemViewControllerUserInfoKey : systemViewController]
        )
    }
}
