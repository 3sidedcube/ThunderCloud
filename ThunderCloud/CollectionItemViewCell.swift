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
    
    /// Fixed constants
    private struct Constants {
        
        /// The padding between the label/image view and the edges of the cell
        static let cellPadding = UIEdgeInsets(top: 10, left: 8, bottom: 12, right: 8)
        
        /// The padding between the title label and the image view
        static let labelPadding = UIEdgeInsets(top: 2, left: 12, bottom: 2, right: 12)
        
        /// Width of the `imageBackgroundView` defined the the xib file.
        /// This is required as the `size(for:)` method is a `class` method, otherwise would
        /// invoke a layout on the instance and get the size that way.
        static let imageBackgroundViewSize: CGFloat = 100
        
        /// Spacing of the `stackView` defined the the xib file.
        static let stackViewSpacing: CGFloat = 6
    }
    
    /// StackView to drive vertical layout
    @IBOutlet weak var stackView: UIStackView!
    
    /// The image view to display the collection item's image
    @IBOutlet public weak var imageView: UIImageView!
    
    /// The label for displaying the title of the collection item
    @IBOutlet public weak var titleLabel: InsetLabel! {
        didSet {
            titleLabel.roundCorners = true
        }
    }

    /// The label for displaying the subtitle of the collection item
    @IBOutlet weak var subtitleLabel: InsetLabel! {
        didSet {
            subtitleLabel.roundCorners = true
        }
    }
    
    /// White background view surrounding the collection item's image
    @IBOutlet public weak var imageBackgroundView: CircleProgressView!
    
    /// The container view for the item's image, so it can be masked to the outer view's corner radius
    @IBOutlet weak var imageContainerView: TSCView!
    
    /// The accessibility label that should be read in place of the title
    var titleAccessibilityLabel: String?
    
    private var labels: [InsetLabel] {
        return [titleLabel, subtitleLabel]
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        clipsToBounds = false
        contentView.clipsToBounds = false
    }
    
    /// Calculates the size of the collection list item for the given item
    ///
    /// - Parameter item: The item which will be rendered
    /// - Returns: The size the items content will occupy
    public class func size(for item: CollectionCellDisplayable) -> CGSize {
        var width = Constants.imageBackgroundViewSize
        var height = Constants.imageBackgroundViewSize
        
        includeLabelDimensions(text: item.title, enabled: item.enabled,
                               width: &width, height: &height)
        includeLabelDimensions(text: item.expiryDateString, enabled: item.enabled,
                               width: &width, height: &height)
        
        return CGSize(
            width: width + Constants.cellPadding.horizontalSum,
            height: height + Constants.cellPadding.verticalSum)
    }
    
    func configure(with item: CollectionCellDisplayable) {
        
        // Accessibility
        titleAccessibilityLabel = item.accessibilityLabel
        imageView.accessibilityLabel = item.itemImage?.accessibilityLabel
        
        // Content
        imageView.image = item.itemImage?.image
        CollectionItemViewCell.configure(
            label: titleLabel, text: item.title, enabled: item.enabled)
        CollectionItemViewCell.configure(
            label: subtitleLabel, text: item.expiryDateString, enabled: item.enabled)
        titleLabel.isHidden = titleLabel.textIsEmpty()
        subtitleLabel.isHidden = subtitleLabel.textIsEmpty()
        imageBackgroundView.alpha = item.enabled ? 1.0 : 0.44
    }
    
    // MARK: - Labels
    
    class func configure(label: InsetLabel, text: String, enabled: Bool) {
        label.insets = Constants.labelPadding
        label.text = text
        label.font = ThemeManager.shared.theme.dynamicFont(
            ofSize: 13, textStyle: .footnote, weight: enabled ? .bold : .regular)
        label.backgroundColor = enabled ? ThemeManager.shared.theme.mainColor : .clear
        label.textColor = enabled ? ThemeManager.shared.theme.whiteColor : ThemeManager.shared.theme.darkGrayColor
        label.numberOfLines = 1
    }
    
    class func labelDimensions(text: String, enabled: Bool) -> CGSize {
        let label = InsetLabel()
        configure(label: label, text: text, enabled: enabled)
        label.sizeToFit()
        return label.frame.size
    }
    
    class func includeLabelDimensions(text: String, enabled: Bool,
                                      width: inout CGFloat, height: inout CGFloat) {
        guard !text.isEmpty else {
            return
        }
        
        let size = labelDimensions(text: text, enabled: enabled)
        width = max(width, size.width)
        height += Constants.stackViewSpacing + size.height
    }
    
    // MARK: - Accessibility
    
    open override var accessibilityTraits: UIAccessibilityTraits {
        get {
            return [.staticText, .button]
        }
        set {
        }
    }
    
    open override var isAccessibilityElement: Bool {
        get {
            return true
        }
        set {
        }
    }
    
    open override var accessibilityElements: [Any]? {
        get {
            return [imageView?.accessibilityLabel != nil ? imageView : nil, titleLabel].compactMap({ $0 })
        }
        set {
        }
    }
    
    override open var accessibilityLabel: String? {
        get {
            return [imageView?.accessibilityLabel, titleAccessibilityLabel].compactMap({ $0 }).joined(separator: ",")
        }
        set {
        }
    }
}

// MARK: - Extensions

extension CollectionCellDisplayable {

    var title: String {
        return itemTitle?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    var expiryDateString: String {
        guard let expiryDate = expiryDate else {
            return ""
        }
        
        return DateFormatter.iso8601Formatter(
            timeZone: TimeZone.current, dateFormat: "dd/MM/yy")
            .string(from: expiryDate)
    }
}

extension UILabel {
    
    /// Is `text` empty. If `nil` return `nilResult`
    func textIsEmpty(nilResult: Bool = true) -> Bool {
        return text?.isEmpty ?? nilResult
    }
}

extension UIEdgeInsets {
    
    /// Sum `left` and `right`
    var horizontalSum: CGFloat {
        return left + right
    }
    
    /// Sum `top` and `bottom`
    var verticalSum: CGFloat {
        return top + bottom
    }
}
