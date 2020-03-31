//
//  BundleDiagnosticsTool.swift
//  ThunderCloud
//
//  Created by Matthew Cheetham on 15/11/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation
import UIKit
import Baymax
import ThunderTable
import UserNotifications

/// A tool for providing info about the current app bundles
class BundleDiagnosticTool: DiagnosticTool {
    
    var displayName: String {
        return "Bundles"
    }
    
    func launchUI(in navigationController: UINavigationController) {
        let diagView = BundleDiagnosticTableViewController(style: .grouped)
        navigationController.show(diagView, sender: self)
    }
}

class BundleDiagnosticTableViewController: TableViewController {
    
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        dateFormatter.timeStyle = .medium
        dateFormatter.dateStyle = .long
        
        navigationController?.navigationBar.prefersLargeTitles = false
        title = "Bundle Information"
        tableView.register(UINib(nibName: "InformationTableViewCell", bundle: Bundle(for: BundleDiagnosticTableViewController.self)), forCellReuseIdentifier: "informationRow")
        
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
        var buildDateString: String = "Unknown"
        if let excPath = Bundle.main.executablePath, let attributes = try? fm.attributesOfItem(atPath: excPath), let date = attributes[.creationDate] as? Date {
            buildDateString = dateFormatter.string(from: date)
        }
        let buildDateRow = TableRow(title: "Build Date", subtitle: buildDateString, image: nil, selectionHandler: nil)
        
        var bundleDateString: String = "Unknown"
        if let bundleTimestamp = timestampOfBundle(in: ContentController.shared.bundleDirectory) {
            bundleDateString = dateFormatter.string(from: Date(timeIntervalSince1970: bundleTimestamp))
        }
        let bundleTimestampRow = TableRow(title: "Bundle", subtitle: bundleDateString, image: nil, selectionHandler: nil)
        
        var deltaDateString: String = "Unknown"
        if let deltaTimestamp = timestampOfBundle(in: ContentController.shared.deltaDirectory) {
            deltaDateString = dateFormatter.string(from: Date(timeIntervalSince1970: deltaTimestamp))
        }
        let deltaTimestampRow = TableRow(title: "Delta", subtitle: deltaDateString, image: nil, selectionHandler: nil)
        
        let deleteDeltaRow = TableRow(title: "Delete Delta Bundle") { [weak self] (_, _, _, _) -> (Void) in
            self?.deleteDeltaBundle()
        }
        
        let switchRow = TableRow(title: DeveloperModeController.appIsInDevMode ? "Switch to Live Content" : "Switch to Test Content") { (_, _, _, _) -> (Void) in
            if DeveloperModeController.appIsInDevMode {
                // Set this for settings.bundle's sake!
                UserDefaults.standard.set(false, forKey: "developer_mode_enabled")
                DeveloperModeController.shared.switchToLive()
            } else {
                // Set this for settings.bundle's sake!
                UserDefaults.standard.set(true, forKey: "developer_mode_enabled")
                DeveloperModeController.shared.loginToDeveloperMode()
            }
        }
        
        data = [
            TableSection(rows: [buildDateRow], header: "Build Information"),
            TableSection(rows: [bundleTimestampRow, deltaTimestampRow], header: "Timestamps"),
            TableSection(rows: [deleteDeltaRow, switchRow], header: "Actions")
        ]
    }
    
    private func deleteDeltaBundle() {
        
        let confirmationAlert = UIAlertController(
            title: "Delete Delta Bundle",
            message: "This will delete the delta bundle and cannot be undone. The app will be killed after this is completed. Are you sure you wish to proceed?",
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
