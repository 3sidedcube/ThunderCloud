//
//  StormTableRow.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 03/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation
import ThunderTable

/// `StormTableRow` is a `TableRow` with added functionality to support right to left languages
class StormTableRow: TableRow {
	
	override var cellClass: AnyClass? {
        return EmbeddedLinksListItemCell.self
	}
	
	override func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		
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
			
			//TODO: Make sure this still works!
//			if (standardCell.cellImageView.image) {
//				
//				view.frame = CGRectMake(cell.frame.size.width - view.frame.origin.x - view.frame.size.width + 20, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
//				
//			} else {
//				
//				if (self.accessoryType != UITableViewCellAccessoryNone) {
//					
//					view.frame = CGRectMake(cell.frame.size.width - view.frame.origin.x - view.frame.size.width - 20, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
//					
//				} else {
//					
//					view.frame = CGRectMake(cell.frame.size.width - view.frame.origin.x - view.frame.size.width, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
//					
//				}
//				
//			}
			
			label.textAlignment = .right
		}
	}
}
