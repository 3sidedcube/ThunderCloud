//
//  BundleDiagnosticsTableViewController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 08/04/2020.
//  Copyright © 2020 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

class BundleDiagnosticTableViewController: TableViewController {
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEEE, MMM d, yyyy HH:mm Z"
        return formatter
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = false
        title = "Bundle Information"
        
        redraw()
    }
    
    // MARK: - Redrawing
    
    private func timestampOfBundle(in directory: URL) -> TimeInterval? {
        let manifestURL = directory.appendingPathComponent("manifest.json")
        guard let jsonObject = try? JSONSerialization.jsonObject(with: manifestURL) else {
           return nil
        }
        guard let manifest = jsonObject as? [AnyHashable : Any] else {
            return nil
        }
        return manifest["timestamp"] as? TimeInterval
    }
    
    func redraw() {
        
        let fm = FileManager.default
        var buildDateString: String?
        if let excPath = Bundle.main.executablePath, let attributes = try? fm.attributesOfItem(atPath: excPath), let date = attributes[.creationDate] as? Date {
            buildDateString = dateFormatter.string(from: date)
        }
        let buildDateRow = StormDiagnosticsRow(title: "Build Date", subtitle: buildDateString ?? "Unknown")
        if let _buildDateString = buildDateString {
            buildDateRow.selectionHandler = { (_, _, _, _) in
                UIPasteboard.general.copy(string: _buildDateString)
            }
        }
        buildDateRow.accessoryView = buildDateString != nil ? .copyAccessoryView : nil
        
        var bundleDateString: String?
        if let bundleDirectory =  ContentController.shared.bundleDirectory, let bundleTimestamp = timestampOfBundle(in: bundleDirectory) {
            bundleDateString = dateFormatter.string(from: Date(timeIntervalSince1970: bundleTimestamp))
        }
        let bundleTimestampRow = StormDiagnosticsRow(title: "Bundle", subtitle: bundleDateString ?? "Unknown")
        if let _bundleDateString = bundleDateString {
            bundleTimestampRow.selectionHandler = { (_, _, _, _) in
                UIPasteboard.general.copy(string: _bundleDateString)
            }
        }
        bundleTimestampRow.accessoryView = bundleDateString != nil ? .copyAccessoryView : nil
        
        var deltaDateString: String?
        if let deltaDirectory = ContentController.shared.deltaDirectory, let deltaTimestamp = timestampOfBundle(in: deltaDirectory) {
            deltaDateString = dateFormatter.string(from: Date(timeIntervalSince1970: deltaTimestamp))
        }
        let deltaTimestampRow = StormDiagnosticsRow(title: "Delta", subtitle: deltaDateString ?? "Unknown")
        if let _deltaDateString = deltaDateString {
            deltaTimestampRow.selectionHandler = { (_, _, _, _) in
                UIPasteboard.general.copy(string: _deltaDateString)
            }
        }
        deltaTimestampRow.accessoryView = deltaDateString != nil ? .copyAccessoryView : nil
        
        let deleteDeltaRow = StormDiagnosticsRow(title: "Delete Delta Bundle") { [weak self] (_, _, _, _) -> (Void) in
            self?.deleteDeltaBundle()
        }
        
        let switchRow = StormDiagnosticsRow(title: DeveloperModeController.appIsInDevMode ? "Switch to Live Content" : "Switch to Test Content") { (_, _, _, _) -> (Void) in
            // We use dev mode on as this reflects the user's preference!
            if DeveloperModeController.devModeOn {
                DeveloperModeController.devModeOn = false
                DeveloperModeController.shared.switchToLive()
            } else {
                DeveloperModeController.devModeOn = true
                DeveloperModeController.shared.loginToDeveloperMode()
            }
        }
            
        let notifyOfDownloadRow = StormDiagnosticsSwitchRow(title: "Notify of Download Feedback", subtitle: "The app will show toast notifications with information on delta download progress", id: "feedback")
        notifyOfDownloadRow.value = ContentController.showFeedback
        notifyOfDownloadRow.valueChangeHandler = { [weak self] (value, _) in
            guard let showFeedback = value as? Bool else { return }
            ContentController.showFeedback = showFeedback
            self?.redraw()
        }
        
        var settingsRows: [Row] = [notifyOfDownloadRow]
        
        if ContentController.showFeedback {
            
            let inBackgroundRow = StormDiagnosticsSwitchRow(title: "Notify in Background", subtitle: "If enabled you will also be sent local notifications when content is downloaded in the background", id: "background")
            inBackgroundRow.value = ContentController.showFeedbackInBackground
            inBackgroundRow.valueChangeHandler = { (value, _) in
                guard let showFeedback = value as? Bool else { return }
                ContentController.showFeedbackInBackground = showFeedback
            }
            
            settingsRows.append(inBackgroundRow)
        }
        
        let downloadOnWifiRow = StormDiagnosticsSwitchRow(title: "Only Download on WiFi", subtitle: "The app will only download delta updates if your phone is connected to a WiFi network", id: "wifi")
        downloadOnWifiRow.value = ContentController.onlyDownloadOverWifi
        downloadOnWifiRow.valueChangeHandler = { (value, _) in
            guard let onlyDownloadOverWifi = value as? Bool else { return }
            ContentController.onlyDownloadOverWifi = onlyDownloadOverWifi
        }
        settingsRows.append(downloadOnWifiRow)
        
        data = [
            TableSection(rows: [buildDateRow], header: "Build Information"),
            TableSection(rows: [bundleTimestampRow, deltaTimestampRow], header: "Timestamps"),
            TableSection(rows: settingsRows, header: "Settings"),
            TableSection(rows: [deleteDeltaRow, switchRow], header: "Actions")
        ]
    }
    
    private func deleteDeltaBundle() {
        
        let confirmationAlert = UIAlertController(
            title: "Delete Delta Bundle",
            message: "This will delete the delta bundle and cannot be undone. The app will be killed after this is completed. Are you sure you wish to proceed?\n\nPlease note this will not stop the delta being re-downloaded on next launch or in the background.",
            preferredStyle: .alert
        )
        confirmationAlert.addAction(UIAlertAction(title: "Yes, delete", style: .destructive, handler: { (action) in
            
            guard let deltaDirectory = ContentController.shared.deltaDirectory else {
                return
            }
            
            ContentController.shared.removeBundle(in: deltaDirectory)
            
            let content = UNMutableNotificationContent()
            content.title = "Delta Deleted"
            content.body = "Tap here to re-launch the app"
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
            
            // Create the request
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
            
            // Schedule the request with the system.
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request, withCompletionHandler: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                exit(0)
            }
            
        }))
        
        confirmationAlert.addAction(UIAlertAction(title: "No, go back", style: .cancel, handler: nil))
        
        present(confirmationAlert, animated: true, completion: nil)

    }
}
