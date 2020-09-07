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
    
    /// Whether to render localisation key along with the value for debugging purposes
    static internal var showDebugLocalisations: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "storm_debug_localisations")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "storm_debug_localisations")
        }
    }
}
