//
//  TSCBadgeScrollerItemViewCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 20/09/2016.
//  Copyright © 2016 threesidedcube. All rights reserved.
//

import UIKit

open class TSCBadgeScrollerItemViewCell: UICollectionViewCell {

    @IBOutlet public weak var badgeImageView: UIImageView!
    
    @IBOutlet public weak var titleLabel: UILabel!
    
    
    open override func awakeFromNib() {
        
        super.awakeFromNib()
        titleLabel.textColor = TSCThemeManager.sharedTheme().cellTitleColor()
    }
}
