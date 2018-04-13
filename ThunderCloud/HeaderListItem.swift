//
//  HeaderListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 05/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// Subclass of `ImageListItem` which displays an image header with a slight dark overlay and centered title text and subtitle
open class HeaderListItem: ImageListItem {
	
	required public init(dictionary: [AnyHashable : Any]) {
		
		super.init(dictionary: dictionary)
		titleTextColor = .white
		detailTextColor = .white
	}

	override open var cellClass: UITableViewCell.Type? {
		return HeaderListItemCell.self
	}
    
    open override func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        
        super.configure(cell: cell, at: indexPath, in: tableViewController)
        
        guard let headerCell = cell as? HeaderListItemCell else { return }
        
        if let imageHeight = imageHeight(constrainedTo: tableViewController.view.frame.width) {
            headerCell.imageHeightConstraint?.constant = imageHeight
        }
        
        headerCell.cellTextLabel?.font = UIFont.preferredFont(forTextStyle: .title1, scaledBy: 1.28)
        headerCell.cellDetailLabel?.font = UIFont.preferredFont(forTextStyle: .body)
    }
}
