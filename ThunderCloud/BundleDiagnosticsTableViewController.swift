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
    
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        dateFormatter.timeStyle = .medium
        dateFormatter.dateStyle = .long
        
        navigationController?.navigationBar.prefersLargeTitles = false
        title = "Bundle Information"
        
        redraw()
    }
    
    // MARK: - Redrawing
    
    private func timestampOfBundle(in directory: URL?) -> TimeInterval? {
        guard let directory = directory else { return nil }
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
        let buildDateRow = StormDiagnosticsRow(title: "Build Date", subtitle: buildDateString ?? "Unknown", image: nil, selectionHandler: { (_, _, _, _) in
            guard let buildDateString = buildDateString else { return }
            UIPasteboard.general.copy(string: buildDateString)
        })
        buildDateRow.accessoryView = buildDateString != nil ? .copyAccessoryView : nil
        
        var bundleDateString: String?
        if let bundleTimestamp = timestampOfBundle(in: ContentController.shared.bundleDirectory) {
            bundleDateString = dateFormatter.string(from: Date(timeIntervalSince1970: bundleTimestamp))
        }
        let bundleTimestampRow = StormDiagnosticsRow(title: "Bundle", subtitle: bundleDateString, image: nil, selectionHandler: { (_, _, _, _) in
            guard let bundleDateString = bundleDateString else { return }
            UIPasteboard.general.copy(string: bundleDateString)
        })
        bundleTimestampRow.accessoryView = bundleDateString != nil ? .copyAccessoryView : nil
        
        var deltaDateString: String?
        if let deltaTimestamp = timestampOfBundle(in: ContentController.shared.deltaDirectory) {
            deltaDateString = dateFormatter.string(from: Date(timeIntervalSince1970: deltaTimestamp))
        }
        let deltaTimestampRow = StormDiagnosticsRow(title: "Delta", subtitle: deltaDateString ?? "Unknown", image: nil, selectionHandler: { (_, _, _, _) in
            guard let deltaDateString = deltaDateString else { return }
            UIPasteboard.general.copy(string: deltaDateString)
        })
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
        notifyOfDownloadRow.valueChangeHandler = { (value, _) in
            guard let showFeedback = value as? Bool else { return }
            ContentController.showFeedback = showFeedback
        }
        
        let downloadOnWifiRow = StormDiagnosticsSwitchRow(title: "Only Download on WiFi", subtitle: "The app will only download delta updates if your phone is connected to a WiFi network", id: "wifi")
        downloadOnWifiRow.value = ContentController.onlyDownloadOverWifi
        downloadOnWifiRow.valueChangeHandler = { (value, _) in
            guard let onlyDownloadOverWifi = value as? Bool else { return }
            ContentController.onlyDownloadOverWifi = onlyDownloadOverWifi
        }
        
        data = [
            TableSection(rows: [buildDateRow], header: "Build Information"),
            TableSection(rows: [bundleTimestampRow, deltaTimestampRow], header: "Timestamps"),
            TableSection(rows: [notifyOfDownloadRow, downloadOnWifiRow], header: "Settings"),
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
                exit(-1)
            }
            
        }))
        
        confirmationAlert.addAction(UIAlertAction(title: "No, go back", style: .cancel, handler: nil))
        
        present(confirmationAlert, animated: true, completion: nil)

    }
}
