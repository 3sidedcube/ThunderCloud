//
//  PushNotificationsTool.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 08/04/2020.
//  Copyright © 2020 threesidedcube. All rights reserved.
//

import Foundation
import Baymax

/// A tool for providing info about the user's push tokens
class PushNotificationsTool: DiagnosticTool {
    
    var displayName: String {
        return "Push Notifications"
    }
    
    func launchUI(in navigationController: UINavigationController) {
        let diagView = PushNotificationsInformationTableViewController(style: .grouped)
        navigationController.show(diagView, sender: self)
    }
}
