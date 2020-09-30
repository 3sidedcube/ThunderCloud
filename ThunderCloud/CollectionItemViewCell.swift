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

// MARK: - CollectionCellDisplayableStyle

/// Previously an item being `enabled` would add a bold font and rounded rect to the label.
/// However for some designs: when there is an `expiryDate`, the title label should not have the `enabled` style.
public enum CollectionCellDisplayableStyle {
    
    /// Regular font, clear background, darkGray textColor
    case `default`
    
    /// Bold font, main background, white textColor
    case boldMain
    
    /// Bold font, darkGray background, white textColor
    case boldGray
    
    // MARK: Style
    
    fileprivate var weight: UIFont.Weight {
        switch self {
        case .default: return .regular
        case .boldMain: return .bold
        case .boldGray: return .bold
        }
    }
    
    fileprivate var backgroundColor: UIColor {
        switch self {
        case .default: return .clear
        case .boldMain: return ThemeManager.shared.theme.mainColor
        case .boldGray: return ThemeManager.shared.theme.darkGrayColor
        }
    }
    
    fileprivate var textColor: UIColor {
        switch self {
        case .default: return ThemeManager.shared.theme.darkGrayColor
        case .boldMain: return ThemeManager.shared.theme.whiteColor
        case .boldGray: return ThemeManager.shared.theme.whiteColor
        }
    }
}

// MARK: - CollectionItemViewCellConfiguration

/// Configure `CollectionItemViewCell`
public struct CollectionItemViewCellConfiguration {
    
    /// Shared `CollectionItemViewCellConfiguration` instance
    public static var shared = CollectionItemViewCellConfiguration()
    
    /// Show circlular progress for items which do not degrade
    public var showProgressForNonExpirableItems = false
    
    /// Fix a  `CollectionCellDisplayableStyle` for the `titleLabel`. This for different designs across apps.
    /// When nil, is `.boldMain` if `enabled`, otherwise `.default`
    public var fixedTitleLabelStyle: CollectionCellDisplayableStyle? = nil
    
    /// Public memberwise init
    public init(showProgressForNonExpirableItems: Bool = false,
                fixedTitleLabelStyle: CollectionCellDisplayableStyle? = nil) {
        self.showProgressForNonExpirableItems = showProgressForNonExpirableItems
        self.fixedTitleLabelStyle = fixedTitleLabelStyle
    }
}

// MARK: - CollectionItemViewCell

/// A UICollectionViewCell for use in a `CollectionListItem`
open class CollectionItemViewCell: UICollectionViewCell {
    
    /// Fixed constants
    private struct Constants {
        
        /// The padding between the label/image view and the edges of the cell
        static let cellPadding = UIEdgeInsets(top: 10, left: 8, bottom: 12, right: 8)
        
        /// The padding between the title label and the image view
        static let labelPadding = UIEdgeInsets(top: 3, left: 16, bottom: 3, right: 16)
                
        /// Width of the `imageBackgroundView` defined the the xib file.
        /// This is required as the `size(for:)` method is a `class` method, otherwise would
        /// invoke a layout on the instance and get the size that way.
        /// - Parameter blendedLearningEnabled: Whether blended learning is enabled
        /// - Returns: The correct image background size
        static func imageBackgroundViewSize(blendedLearningEnabled: Bool) -> CGFloat {
            return blendedLearningEnabled ? 94 : 76
        }
        
        /// Spacing of the `stackView` defined the the xib file.
        static let stackViewSpacing: CGFloat = 4
    }
    
    /// StackView to drive vertical layout
    @IBOutlet weak var stackView: UIStackView!
    
    /// The image view to display the collection item's image
    @IBOutlet public weak var imageView: UIImageView!
    
    /// The label for displaying the title of the collection item
    @IBOutlet public weak var titleLabel: InsetLabel!

    /// The label for displaying the subtitle of the collection item
    @IBOutlet weak var subtitleLabel: InsetLabel!
    
    /// White background view surrounding the collection item's image
    @IBOutlet public weak var imageBackgroundView: CircleProgressView!
    
    /// The container view for the item's image, so it can be masked to the outer view's corner radius
    @IBOutlet weak var imageContainerView: UIView! {
        didSet {
            imageContainerView.clipsToBounds = true
        }
    }
    
    /// The width constraint for the image view container
    @IBOutlet weak var imageContainerWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topInsetConstraint: NSLayoutConstraint!
    
    /// Setting this will adjust the margins between the image view and it's container.
    /// This is used to inset the image when blended-learning is not enabled for an app.
    public var imageViewMargins: UIEdgeInsets = .zero {
        didSet {
            imageViewLeadingConstraint.constant = imageViewMargins.left
            imageViewTrailingConstraint.constant = imageViewMargins.right
            imageViewTopConstraint.constant = imageViewMargins.top
            imageViewBottomConstraint.constant = imageViewMargins.bottom
        }
    }
    
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
        var width = Constants.imageBackgroundViewSize(blendedLearningEnabled: QuizConfiguration.shared.isBlendedLearningEnabled)
        var height = width
        
        includeLabelDimensions(text: item.title, style: item.titleStyle,
                               width: &width, height: &height)
        includeLabelDimensions(text: item.expiryDateString, style: item.expiryStyle,
                               width: &width, height: &height)
        
        
        
        return CGSize(
            width: width + Constants.cellPadding.horizontalSum,
            height: height + Constants.cellPadding.verticalSum)
    }
    
    func configure(with item: CollectionCellDisplayable) {
        
        // Accessibility
        titleAccessibilityLabel = item.accessibilityLabel
        imageView.accessibilityLabel = item.itemImage?.accessibilityLabel
        
        imageContainerWidthConstraint.constant = Constants.imageBackgroundViewSize(blendedLearningEnabled: QuizConfiguration.shared.isBlendedLearningEnabled)
        
        // Content
        imageView.image = item.itemImage?.image
        CollectionItemViewCell.configure(
            label: titleLabel, text: item.title, style: item.titleStyle)
        CollectionItemViewCell.configure(
            label: subtitleLabel, text: item.expiryDateString, style: item.expiryStyle)
                
        // Don't need to handle re-use here as this shouldn't change on a reload-by-reload basis!
        if QuizConfiguration.shared.isBlendedLearningEnabled {
            
            imageBackgroundView.alpha = item.enabled ? 1.0 : 0.44
            
            // Progress
            imageBackgroundView.badgeConfigure()
            
            // Default for items which are completed which don't expire is 1
            let showProgressIfEnabled = CollectionItemViewCellConfiguration.shared.showProgressForNonExpirableItems
            let def: Float = (item.enabled && showProgressIfEnabled) ? 1 : 0
            imageBackgroundView.progress = CGFloat(item.expirableAchievement?.progress ?? def)
            imageViewMargins = .zero
            
        } else {
            
            imageViewMargins = .init(top: 6, left: 6, bottom: 6, right: 6)
            imageBackgroundView.alpha = 1
            imageBackgroundView.progress = 0
            imageBackgroundView.circleProgressLayer.backgroundPathColor = imageBackgroundView.backgroundColor ?? .white
            
            imageBackgroundView.shadowRadius = 36
            imageBackgroundView.shadowColor = UIColor.black
            imageBackgroundView.shadowOffset = CGSize(width: 0, height: 10)
            imageBackgroundView.shadowOpacity = 0.1
            
            imageView.alpha = item.enabled ? 1.0 : 0.4
        }

        accessibilityTraits = item.accessibilityTraits
        accessibilityHint = item.accessibilityHint
    }

    // MARK: - Labels
    
    fileprivate static func configure(label: InsetLabel, text: String, style: CollectionCellDisplayableStyle) {
        label.insets = Constants.labelPadding
        label.text = text
        label.font = ThemeManager.shared.theme.dynamicFont(
            ofSize: 13, textStyle: .footnote, weight: style.weight)
        label.backgroundColor = style.backgroundColor
        label.textColor = style.textColor
        label.numberOfLines = 1
        label.isHidden = text.isEmpty
    }
    
    fileprivate static func labelDimensions(text: String, style: CollectionCellDisplayableStyle) -> CGSize {
        let label = InsetLabel()
        configure(label: label, text: text, style: style)
        label.sizeToFit()
        return label.frame.size
    }
    
    fileprivate static func includeLabelDimensions(text: String, style: CollectionCellDisplayableStyle,
                                      width: inout CGFloat, height: inout CGFloat) {
        guard !text.isEmpty else {
            return
        }
        
        let size = labelDimensions(text: text, style: style)
        width = max(width, size.width)
        height += Constants.stackViewSpacing + size.height
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
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        // Set imageContainerView to circular so it masks `imageView`
        imageContainerView.layer.cornerRadius = imageContainerView.bounds.width/2
    }
}

// MARK: - Extensions

extension CollectionCellDisplayable {

    /// Top label text
    var title: String {
        return itemTitle?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    /// Bottom label text
    var expiryDateString: String {
        return expirableAchievement?.expiryDateString ?? ""
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

extension CollectionCellDisplayable {
    
    fileprivate var titleStyle: CollectionCellDisplayableStyle {
        if let style = CollectionItemViewCellConfiguration.shared.fixedTitleLabelStyle {
            return style
        }
        return enabled ? .boldMain : .default
    }
    
    fileprivate var expiryStyle: CollectionCellDisplayableStyle {
        return .boldGray
    }
    
}
