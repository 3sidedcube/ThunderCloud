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

open class CollectionItemViewCell: UICollectionViewCell {
    
    private static let widthCalculationLabel = UILabel(frame: .zero)
    
    /// The padding between the label/image view and the edges of the cell
    static let cellPadding = UIEdgeInsets(top: 10, left: 8, bottom: 12, right: 8)
    
    /// The padding between the title label and the image view
    static let labelPadding = UIEdgeInsets(top: 2, left: 12, bottom: 2, right: 12)
    
    /// The spacing between the title label and the image view
    static let labelImageSpacing: CGFloat = 6.0

    @IBOutlet public weak var imageView: UIImageView!
    
    @IBOutlet public weak var titleLabel: UILabel!
    
    @IBOutlet public weak var titleContainerView: TSCView!
    
    @IBOutlet public weak var imageBackgroundView: TSCView!
    
    override open func awakeFromNib() {
        
        super.awakeFromNib()
        titleLabel.textColor = ThemeManager.shared.theme.cellTitleColor
        
        imageBackgroundView.clipsToBounds = false
        clipsToBounds = false
        contentView.clipsToBounds = false
        
        imageBackgroundView.shadowRadius = 32
        imageBackgroundView.shadowColor = .black
        imageBackgroundView.shadowOffset = CGPoint(x: 0, y: 10)
        imageBackgroundView.shadowOpacity = 0.1
        
        imageBackgroundView.borderWidth = 1.0/UIScreen.main.scale
        imageBackgroundView.borderColor = UIColor(white: 0.0, alpha: 0.04)
    }
    
    /// Calculates the size of the collection list item for the given badge
    ///
    /// - Parameter badge: The badge which will be rendered
    /// - Returns: The size the badges content will occupy
    public class func size(for item: CollectionCellDisplayable) -> CGSize {
        
        let selected = item.selected
        //TODO: Add to badge implementation!
//        let hasEarnt = badge.id != nil ? BadgeController.shared.hasEarntBadge(with: badge.id!) : false
        
        let cellWidthPadding = CollectionItemViewCell.cellPadding.left + CollectionItemViewCell.cellPadding.right
        let cellHeightPadding = CollectionItemViewCell.cellPadding.top + CollectionItemViewCell.cellPadding.bottom
        
        guard let title = item.itemTitle, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return CGSize(width: 76 + cellWidthPadding, height: 76 + cellHeightPadding)
        }
        
        let widthLabel = CollectionItemViewCell.widthCalculationLabel
        widthLabel.text = title
        widthLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 13, textStyle: .footnote, weight: selected ? .bold : .regular)
        widthLabel.numberOfLines = 1
        widthLabel.sizeToFit()
        
        // minimum 76 as that's what we restrict the image view's width to
        let labelPadding = CollectionItemViewCell.labelPadding.left + CollectionItemViewCell.labelPadding.right
        let contentWidth = max(76, widthLabel.frame.width + labelPadding)
        let width = contentWidth + cellWidthPadding
        
        let labelHeightPadding = CollectionItemViewCell.labelPadding.bottom + CollectionItemViewCell.labelPadding.top
        let height = cellHeightPadding + 76 + labelHeightPadding + CollectionItemViewCell.labelImageSpacing + widthLabel.frame.height
        
        return CGSize(width: width, height: height)
    }
    
    func configure(with item: CollectionCellDisplayable) {
        
        imageView.accessibilityLabel = item.itemImageAccessibilityLabel
        imageView.image = item.itemImage
        titleLabel.text = item.itemTitle
        
        if let title = item.itemTitle, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            titleContainerView.isHidden = false
        } else {
            titleContainerView.isHidden = true
        }
        
        let selected = item.selected

        imageView.alpha = selected ? 1.0 : 0.44
        titleLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 13, textStyle: .footnote, weight: selected ? .bold : .regular)
        titleContainerView.backgroundColor = selected ? ThemeManager.shared.theme.mainColor : .clear
        titleLabel.textColor = selected ? ThemeManager.shared.theme.whiteColor : ThemeManager.shared.theme.darkGrayColor
    }
}
