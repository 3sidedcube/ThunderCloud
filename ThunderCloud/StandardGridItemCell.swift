//
//  StandardGridItemCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 16/02/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

class StandardGridItemCell: UICollectionViewCell {

	@IBOutlet weak var imageView: ImageView!
	
	@IBOutlet weak var titleLabel: UILabel!
	
	@IBOutlet weak var subtitleLabel: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
