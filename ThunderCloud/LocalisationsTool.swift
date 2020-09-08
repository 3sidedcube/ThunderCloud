//
//  LocalisationsTool.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 07/09/2020.
//  Copyright © 2020 threesidedcube. All rights reserved.
//

import Foundation
import Baymax

/// A tool for providing localisation debugging tools
class LocalisationsTool: DiagnosticTool {
    
    var displayName: String {
        return "Localisations"
    }
    
    func launchUI(in navigationController: UINavigationController) {
        let tableViewController = LocalisationsTableViewController(style: .grouped)
        navigationController.show(tableViewController, sender: nil)
    }
    
    private static var _showDebugLocalisations: Bool?
    
    /// Whether to render localisation key along with the value for debugging purposes
    static internal var showDebugLocalisations: Bool {
        get {
            if let _showDebugLocalisations = _showDebugLocalisations {
                return _showDebugLocalisations
            }
            let defaultsShowDebugLocalisations = UserDefaults.standard.bool(forKey: "storm_debug_localisations")
            _showDebugLocalisations = defaultsShowDebugLocalisations
            return defaultsShowDebugLocalisations
        }
        set {
            _showDebugLocalisations = newValue
            UserDefaults.standard.set(newValue, forKey: "storm_debug_localisations")
        }
    }
}
