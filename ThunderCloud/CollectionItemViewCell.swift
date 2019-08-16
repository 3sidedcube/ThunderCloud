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

/// A UICollectionViewCell for use in a `CollectionListItem`
open class CollectionItemViewCell: UICollectionViewCell {
    
    @IBOutlet weak var pinImageToBottomConstraint: NSLayoutConstraint!
    
    private static let widthCalculationLabel = UILabel(frame: .zero)
    
    /// The padding between the label/image view and the edges of the cell
    static let cellPadding = UIEdgeInsets(top: 10, left: 8, bottom: 12, right: 8)
    
    /// The padding between the title label and the image view
    static let labelPadding = UIEdgeInsets(top: 2, left: 12, bottom: 2, right: 12)
    
    /// The spacing between the title label and the image view
    static let labelImageSpacing: CGFloat = 6.0

    /// The image view to display the collection item's image
    @IBOutlet public weak var imageView: UIImageView!
    
    /// The label for displaying the title of the collection item
    @IBOutlet public weak var titleLabel: UILabel!
    
    /// The container view for the title of the collection item. Changes colour based on selected state
    @IBOutlet public weak var titleContainerView: TSCView!
    
    /// White background view surrounding the collection item's image
    @IBOutlet public weak var imageBackgroundView: TSCView!
    
    override open func awakeFromNib() {
        
        super.awakeFromNib()
        titleLabel.textColor = ThemeManager.shared.theme.cellTitleColor
        
        imageBackgroundView.clipsToBounds = false
        clipsToBounds = false
        contentView.clipsToBounds = false
        
        imageView.cornerRadius = 32
        
        imageBackgroundView.shadowRadius = 32
        imageBackgroundView.shadowColor = .black
        imageBackgroundView.shadowOffset = CGPoint(x: 0, y: 10)
        imageBackgroundView.shadowOpacity = 0.1
        
        imageBackgroundView.borderWidth = 1.0/UIScreen.main.scale
        imageBackgroundView.borderColor = UIColor(white: 0.0, alpha: 0.04)
    }
    
    /// Calculates the size of the collection list item for the given item
    ///
    /// - Parameter item: The item which will be rendered
    /// - Returns: The size the items content will occupy
    public class func size(for item: CollectionCellDisplayable) -> CGSize {
        
        let enabled = item.enabled
        
        let cellWidthPadding = CollectionItemViewCell.cellPadding.left + CollectionItemViewCell.cellPadding.right
        let cellHeightPadding = CollectionItemViewCell.cellPadding.top + CollectionItemViewCell.cellPadding.bottom
        
        guard let title = item.itemTitle, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return CGSize(width: 76 + cellWidthPadding, height: 76 + cellHeightPadding)
        }
        
        let widthLabel = CollectionItemViewCell.widthCalculationLabel
        widthLabel.text = title
        widthLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 13, textStyle: .footnote, weight: enabled ? .bold : .regular)
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
            pinImageToBottomConstraint.priority = UILayoutPriority(rawValue: 200)
            titleContainerView.isHidden = false
        } else {
            pinImageToBottomConstraint.priority = UILayoutPriority(rawValue: 999)
            titleContainerView.isHidden = true
        }
        
        let enabled = item.enabled

        imageView.alpha = enabled ? 1.0 : 0.44
        imageBackgroundView.alpha = enabled ? 1.0 : 0.44
        titleLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 13, textStyle: .footnote, weight: enabled ? .bold : .regular)
        titleContainerView.backgroundColor = enabled ? ThemeManager.shared.theme.mainColor : .clear
        titleLabel.textColor = enabled ? ThemeManager.shared.theme.whiteColor : ThemeManager.shared.theme.darkGrayColor
    }
}
