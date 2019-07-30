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
        return StormObjectFactory.shared.class(for: String(describing: EmbeddedLinksListItemCell.self)) as? EmbeddedLinksListItemCell.Type ?? EmbeddedLinksListItemCell.self
	}
	
    override open func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		
		super.configure(cell: cell, at: indexPath, in: tableViewController)
		
		guard let tableCell = cell as? EmbeddedLinksListItemCell else { return }
		
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
