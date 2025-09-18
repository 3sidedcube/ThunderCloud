//
//  ThunderCloudService.swift
//  ThunderCloud
//
//  Created by Matthew Cheetham on 15/11/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import UIKit
import Baymax

class ThunderCloudService: DiagnosticsServiceProvider {
    var serviceName: String {
        return "ThunderCloud"
    }
    
    var diagnosticTools: [DiagnosticTool] {
        return [BundleDiagnosticTool(), PushNotificationsTool(), LocalisationsTool()]
    }
}
