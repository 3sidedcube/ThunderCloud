//
//  StandardGridItemCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 16/02/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// A standard subclass of `UICollectionViewCell`.
/// Displays the image view centered above the title label then subtitle label.
open class StandardGridItemCell: UICollectionViewCell {

	@IBOutlet weak public var imageView: UIImageView?
	
	@IBOutlet weak public var titleLabel: UILabel?
	
	@IBOutlet weak public var subtitleLabel: UILabel?
}
