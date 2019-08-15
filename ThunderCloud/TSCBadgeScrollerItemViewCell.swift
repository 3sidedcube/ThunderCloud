//
//  TSCBadgeScrollerItemViewCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 20/09/2016.
//  Copyright © 2016 threesidedcube. All rights reserved.
//

import UIKit
import ThunderBasics
import ThunderTable

open class TSCBadgeScrollerItemViewCell: UICollectionViewCell {
    
    /// The padding between the label/image view and the edges of the cell
    static let cellPadding = UIEdgeInsets(top: 10, left: 8, bottom: 12, right: 8)
    
    /// The padding between the title label and the image view
    static let labelPadding = UIEdgeInsets(top: 2, left: 12, bottom: 2, right: 12)
    
    /// The spacing between the title label and the image view
    static let labelImageSpacing: CGFloat = 6.0

    @IBOutlet public weak var badgeImageView: UIImageView!
    
    @IBOutlet public weak var titleLabel: UILabel!
    
    @IBOutlet weak var titleContainerView: TSCView!
    
    override open func awakeFromNib() {
        
        super.awakeFromNib()
        titleLabel.textColor = ThemeManager.shared.theme.cellTitleColor
    }
}
