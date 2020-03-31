//
//  StormDiagnosticsRow.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 31/03/2020.
//  Copyright © 2020 threesidedcube. All rights reserved.
//

import Foundation
import ThunderTable

class StormDiagnosticsRow: TableRow {
    
    override func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        guard let tableCell = cell as? TableViewCell else { return }
        tableCell.cellTextLabel?.font = ThemeManager.shared.theme.dynamicFont(ofSize: 17, textStyle: .body, weight: .bold)
        tableCell.cellDetailLabel?.font = ThemeManager.shared.theme.dynamicFont(ofSize: 15, textStyle: .body)
    }
}
