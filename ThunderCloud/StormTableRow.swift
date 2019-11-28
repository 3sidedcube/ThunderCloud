//
//  StormTableRow.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 03/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// `StormTableRow` is a `TableRow` with added functionality to support right to left languages
open class StormTableRow: TableRow {
	
    override open var cellClass: UITableViewCell.Type? {
        return StormObjectFactory.shared.class(for: String(describing: StormTableViewCell.self)) as? StormTableViewCell.Type ?? StormTableViewCell.self
	}
	
    override open func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		
		super.configure(cell: cell, at: indexPath, in: tableViewController)
		
		guard let tableCell = cell as? StormTableViewCell else { return }
        
        tableCell.cellTextLabel?.isHidden = title == nil || title!.isEmpty
        tableCell.cellDetailLabel?.isHidden = subtitle == nil || subtitle!.isEmpty
        
        tableCell.cellImageView?.isHidden = image == nil && imageURL == nil
        tableCell.cellTextLabel?.font = ThemeManager.shared.theme.cellTitleFont
        tableCell.cellDetailLabel?.font = ThemeManager.shared.theme.cellDetailFont
		
		// If we have no links make sure to get rid of the spacing on mainStackView
		tableCell.mainStackView?.spacing = 0
		tableCell.embeddedLinksStackView.isHidden = true
				
		guard StormLanguageController.shared.isRightToLeft else { return }
		
		tableCell.contentView.subviews.forEach { (view) in
			guard let label = view as? UILabel else {
				return
			}
			
			label.textAlignment = .right
		}
	}
}
