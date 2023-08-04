//
//  UIApplication+Extensions.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 21/09/2021.
//  Copyright © 2021 threesidedcube. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    
    /// First `UIWindow` where `isKeyWindow`
    var appKeyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first { $0.isKeyWindow }
    }

    /// `CGRect` frame of the status bar
    var appStatusBarFrame: CGRect {
        guard #available(iOS 13, *) else {
            return statusBarFrame
        }

        let windowScene = appKeyWindow?.windowScene
        return windowScene?.statusBarManager?.statusBarFrame ?? .zero
    }
    
    /// `UIInterfaceOrientation` of the status bar
    var appStatusBarOrientation: UIInterfaceOrientation {
        guard #available(iOS 13, *) else {
            return statusBarOrientation
        }
        
        let windowScene = appKeyWindow?.windowScene
        return windowScene?.interfaceOrientation ?? .unknown
    }
}
