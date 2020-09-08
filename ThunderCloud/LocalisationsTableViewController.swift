//
//  LocalisationsTableViewController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 07/09/2020.
//  Copyright © 2020 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

class LocalisationsTableViewController: TableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        title = "Localisations"
        redraw()
    }
    
    // MARK: - Redrawing

    func redraw() {
        let debugRow = StormDiagnosticsSwitchRow(
            title: "Debug Localisations",
            subtitle: "Enabling this will pre-pend the localisation key to all strings that are localised in the UI to make it easy to spot hard-coded strings",
            id: "debug"
        )
        debugRow.value = LocalisationsTool.showDebugLocalisations
        debugRow.valueChangeHandler = { [weak self] (value, _) in
            guard let debug = value as? Bool else { return }
            LocalisationsTool.showDebugLocalisations = debug
            self?.showQuitAppAlert()
        }
        
        data = [[debugRow]]
    }
    
    func showQuitAppAlert() {
        let alertController = UIAlertController(
            title: "Debugging Localisations Changed",
            message: "Please force-quit the app and restart it for the change to fully take effect.",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
