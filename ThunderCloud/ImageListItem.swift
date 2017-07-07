//
//  ImageListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 05/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// A subclass of `ListItem` which displays an image in the table row at it's original aspect ratio
open class ImageListItem: ListItem {
	
	override public var cellClass: AnyClass? {
		return TableImageViewCell.self
	}
	
	override public var image: UIImage? {
		get {
			if super.image == nil {
				
				let bundle = Bundle(for: ImageListItem.self)
				let transparentImage = UIImage(named: "transparent", in: bundle, compatibleWith: nil)
				return transparentImage?.resizableImage(withCapInsets: .zero, resizingMode: .tile)
			}
			
			return super.image
		}
		set {
			super.image = newValue
		}
	}
	
	override public func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		
		super.configure(cell: cell, at: indexPath, in: tableViewController)
		
		guard let imageCell = cell as? TableImageViewCell else { return }
		imageCell.cellImageView.contentMode = .scaleAspectFill
		imageCell.layer.masksToBounds = true
	}
}
