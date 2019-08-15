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

open class BadgeScrollerItemViewCell: UICollectionViewCell {
    
    private static let widthCalculationLabel = UILabel(frame: .zero)
    
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
    
    /// Calculates the size of the collection list item for the given badge
    ///
    /// - Parameter badge: The badge which will be rendered
    /// - Returns: The size the badges content will occupy
    public class func sizeFor(badge: Badge) -> CGSize {
        
        let hasEarnt = badge.id != nil ? BadgeController.shared.hasEarntBadge(with: badge.id!) : false
        
        let cellWidthPadding = BadgeScrollerItemViewCell.cellPadding.left + BadgeScrollerItemViewCell.cellPadding.right
        let cellHeightPadding = BadgeScrollerItemViewCell.cellPadding.top + BadgeScrollerItemViewCell.cellPadding.bottom
        
        guard let title = badge.title, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return CGSize(width: 76 + cellWidthPadding, height: 76 + cellHeightPadding)
        }
        
        let widthLabel = BadgeScrollerItemViewCell.widthCalculationLabel
        widthLabel.text = title
        widthLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 13, textStyle: .footnote, weight: hasEarnt ? .bold : .regular)
        widthLabel.numberOfLines = 1
        widthLabel.sizeToFit()
        
        // minimum 76 as that's what we restrict the image view's width to
        let labelPadding = BadgeScrollerItemViewCell.labelPadding.left + BadgeScrollerItemViewCell.labelPadding.right
        let contentWidth = max(76, widthLabel.frame.width + labelPadding)
        let width = contentWidth + cellWidthPadding
        
        let labelHeightPadding = BadgeScrollerItemViewCell.labelPadding.bottom + BadgeScrollerItemViewCell.labelPadding.top
        let height = cellHeightPadding + 76 + labelHeightPadding + BadgeScrollerItemViewCell.labelImageSpacing + widthLabel.frame.height
        
        return CGSize(width: width, height: height)
    }
    
    func configureWith(badge: Badge) {
        
        badgeImageView.accessibilityLabel = badge.iconAccessibilityLabel
        badgeImageView.image = badge.icon
        titleLabel.text = badge.title
        
        if let title = badge.title, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            titleContainerView.isHidden = false
        } else {
            titleContainerView.isHidden = true
        }
        
        let hasEarnt = badge.id != nil ? BadgeController.shared.hasEarntBadge(with: badge.id!) : false
        badgeImageView.alpha = hasEarnt ? 1.0 : 0.44
        titleLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 13, textStyle: .footnote, weight: hasEarnt ? .bold : .regular)
        titleContainerView.backgroundColor = hasEarnt ? ThemeManager.shared.theme.mainColor : .clear
        titleLabel.textColor = hasEarnt ? ThemeManager.shared.theme.whiteColor : ThemeManager.shared.theme.darkGrayColor
    }
}
