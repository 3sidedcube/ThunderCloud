//
//  BundleDiagnosticsTool.swift
//  ThunderCloud
//
//  Created by Matthew Cheetham on 15/11/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation
import Baymax

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
