//
//  PushNotificationsInformationTableViewController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 08/04/2020.
//  Copyright © 2020 threesidedcube. All rights reserved.
//

import UIKit
import ThunderBasics
import ThunderTable

extension UIView {
    
    static var copyAccessoryView: UIView {
        let imageView = UIImageView(image: (#imageLiteral(resourceName: "icon-copy") as StormImageLiteral).image)
        imageView.tintColor = .systemBlue
        return imageView
    }
}

extension UIPasteboard {
    
    /// Copies the given string to the paste board, showing a toast notification on completion (If requesteD)
    /// - Parameters:
    ///   - string: The string to copy
    ///   - showToast: Whether to show a toast!
    func copy(string: String, showToast: Bool = true) {
        self.string = string
        guard showToast else { return }
        ToastNotificationController.shared.displayToastWith(title: "Text Copied!", message: nil)
    }
}

extension UNAuthorizationStatus {
    var description: String {
        switch self {
        case .notDetermined:
            return "Not yet requested"
        case .authorized:
            return "Authorized"
        case .denied:
            return "Denied"
        case .provisional:
            return "Provisional (Silent pushes allowed)"
        @unknown default:
            return "Unknown"
        }
    }
}

extension UNNotificationSetting {
    var description: String {
        switch self {
        case .disabled:
            return "Disabled"
        case .enabled:
            return "Enabled"
        case .notSupported:
            return "Not Supported"
        @unknown default:
            return "Unknown"
        }
    }
}

extension UNAlertStyle {
    var description: String {
        switch self {
        case .alert:
            return "Alert"
        case .banner:
            return "Banner"
        case .none:
            return "None"
        @unknown default:
            return "Unknown"
        }
    }
}

extension UNShowPreviewsSetting {
    var description: String {
        switch self {
        case .always:
            return "Always"
        case .never:
            return "Never"
        case .whenAuthenticated:
            return "When unlocked (Default)"
        @unknown default:
            return "Unknown"
        }
    }
}

class PushNotificationsInformationTableViewController: TableViewController {
        
    override func viewDidLoad() {
        
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = false
        title = "Push Notifications"
        
        redraw()
        
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] (settings) in
            self?.notificationSettings = settings
            self?.redraw()
        }
    }
    
    var notificationSettings: UNNotificationSettings? = nil
    
    // MARK: - Redrawing
    
    func redraw() {
        
        var sections: [Section] = []
        
        let tokenRow: StormDiagnosticsRow
        
        if let token = UserDefaults.standard.string(forKey: "TSCPushToken") {
            tokenRow = StormDiagnosticsRow(title: "Token", subtitle: token, selectionHandler: { (_, _, _, _) in
                UIPasteboard.general.copy(string: token)
            })
            tokenRow.accessoryView = .copyAccessoryView
        } else {
            tokenRow = StormDiagnosticsRow(title: "Token", subtitle: "Not yet registered with the CMS")
        }
        
        sections.append([tokenRow])
        
        if let notificationSettings = notificationSettings {
            
            let authorizationStatusRow = StormDiagnosticsRow(title: "Authorization", subtitle: notificationSettings.authorizationStatus.description)
            
            sections.append([authorizationStatusRow])
            
            let alertsRow = StormDiagnosticsRow(title: "Banners", subtitle: notificationSettings.alertSetting.description)
            var alertStylesRows: [Row] = [alertsRow]
            if notificationSettings.alertSetting == .enabled {
                let stylesRow = StormDiagnosticsRow(title: "Banner Style", subtitle: notificationSettings.alertStyle.description)
                alertStylesRows.append(stylesRow)
            }
            alertStylesRows.append(StormDiagnosticsRow(title: "Lock Screen", subtitle: notificationSettings.lockScreenSetting.description))
            alertStylesRows.append(StormDiagnosticsRow(title: "Notification Centre", subtitle: notificationSettings.notificationCenterSetting.description))
            alertStylesRows.append(StormDiagnosticsRow(title: "Car Play", subtitle: notificationSettings.carPlaySetting.description))
            
            sections.append(alertStylesRows)
            
            let soundsRow = StormDiagnosticsRow(title: "Sounds", subtitle: notificationSettings.soundSetting.description)
            let badgesRow = StormDiagnosticsRow(title: "Badges", subtitle: notificationSettings.badgeSetting.description)
            var settingsRows: [Row] = [soundsRow, badgesRow]
            if #available(iOS 12.0, *) {
                let criticalAlertsRow = StormDiagnosticsRow(title: "Critical Alerts", subtitle: notificationSettings.criticalAlertSetting.description)
                settingsRows.append(criticalAlertsRow)
            }
            
            sections.append(settingsRows)
            
            let showPreviewsRow = StormDiagnosticsRow(title: "Show Previews", subtitle: notificationSettings.showPreviewsSetting.description)
            
            sections.append(TableSection(rows: [showPreviewsRow], header: "Options"))
            
        } else {
            
            sections.append(TableSection(rows: [StormDiagnosticsRow(title: "Loading...")], header: "Notification Settings"))
        }
        
        data = sections
    }
}
