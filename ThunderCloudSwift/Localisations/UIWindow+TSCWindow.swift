//
//  UIWindow+TSCWindow.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 17/09/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

import UIKit

/**
 An extension on `UIWindow` that enables editing of localizations
 by responding to a system-wide shake gesture.
 */
extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard
            !(Bundle.main.infoDictionary?["TSCStormLoginDisabled"] as? Bool ?? true),
            motion == .motionShake
        else { return }

        // Attempt to disable editing localizations for app store releases.
        #if DEBUG
        LocalisationController.shared.toggleEditing()
        #else
        if Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") != nil {
            LocalisationController.shared().toggleEditing()
        }
        #endif
    }
}
