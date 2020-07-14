//
//  StormDiagnosticsSwitchRow.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 08/04/2020.
//  Copyright © 2020 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

class StormDiagnosticsSwitchRow: InputSwitchRow {
        
    override func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        
        super.configure(cell: cell, at: indexPath, in: tableViewController)
                
        guard let tableCell = cell as? InputSwitchViewCell else { return }
        
        tableCell.cellTextLabel?.font = ThemeManager.shared.theme.dynamicFont(ofSize: 17, textStyle: .body, weight: .bold)
        tableCell.cellDetailLabel?.font = ThemeManager.shared.theme.dynamicFont(ofSize: 15, textStyle: .body)
    }
}
