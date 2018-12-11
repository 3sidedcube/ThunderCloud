//
//  StandardGridItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 16/02/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import UIKit
import ThunderCollection

/// `StandardGridItem` is a subclass of `GridItem` it represents a row with an item with a title, description and image. It is an adapter for the object in the CMS. All logic is done on it's super.
open class StandardGridItem: GridItem {

	open override var cellClass: UICollectionViewCell.Type? {
		return StandardGridItemCell.self
	}
	
	open override func configure(cell: UICollectionViewCell, at indexPath: IndexPath, in collectionViewController: CollectionViewController) {
		
		guard let standardCell = cell as? StandardGridItemCell else { return }
		
		standardCell.imageView?.isHidden = image == nil
		standardCell.imageView?.image = image
		standardCell.titleLabel?.isHidden = title == nil || title!.isEmpty
		standardCell.titleLabel?.text = title
		standardCell.subtitleLabel?.isHidden = description == nil || description!.isEmpty
		standardCell.subtitleLabel?.text = description
	}
}
