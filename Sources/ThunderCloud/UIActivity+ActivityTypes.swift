//
//  UIActivity+ActivityTypes.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 16/03/2021.
//  Copyright © 2021 threesidedcube. All rights reserved.
//

import Foundation
import UIKit

// MARK: - UIActivity.ActivityType + ActivityTypes

public extension UIActivity.ActivityType {

    /// Slack messaging app
    static let slack = UIActivity.ActivityType(
        rawValue: "com.tinyspeck.chatlyio.share"
    )

    /// Facebook messenger app
    static let fbMessenger = UIActivity.ActivityType(
        rawValue: "com.facebook.Messenger.ShareExtension"
    )

    /// WhatsApp messaging app
    static let whatsApp = UIActivity.ActivityType(
        rawValue: "net.whatsapp.WhatsApp.ShareExtension"
    )
}
