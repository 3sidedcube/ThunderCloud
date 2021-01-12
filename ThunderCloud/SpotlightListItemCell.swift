//
//  SpotlightImageListItemViewCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 03/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderBasics
import ThunderTable

public class SpotlightCollectionViewCell: UICollectionViewCell {
    
    static let heightCalculationLabel = UILabel(frame: .zero)
    
    @IBOutlet public weak var categoryLabel: UILabel!
    
    @IBOutlet public weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet public weak var imageView: UIImageView!
    
    @IBOutlet public weak var titleLabel: UILabel!
    
    @IBOutlet weak var titleContainerView: UIView!
    
    @IBOutlet weak var shadowView: UIView!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var labelsStackView: UIStackView!
    
    @IBOutlet weak var contentLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var contentTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var contentBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var contentTopConstraint: NSLayoutConstraint!
        
    @IBOutlet weak var imageTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var imageLeadingConstraint: NSLayoutConstraint!

    @IBOutlet weak var imageTrailingConstraint: NSLayoutConstraint!

    @IBOutlet weak var imageBottomConstraint: NSLayoutConstraint!

    public override func awakeFromNib() {
        super.awakeFromNib()
        
        shadowView.layer.cornerRadius = SpotlightListItemCell.cornerRadius
        shadowView.layer.masksToBounds = true
        containerView.layer.cornerRadius = SpotlightListItemCell.cornerRadius
        containerView.layer.masksToBounds = true
        containerView.layer.borderWidth = SpotlightListItemCell.borderWidth
        containerView.layer.borderColor = UIColor(white: 0.761, alpha: 1.0).cgColor

        if #available(iOS 13.0, *) {
            shadowView.layer.cornerCurve = .continuous
            containerView.layer.cornerCurve = .continuous
        }
        
        imageView.layer.borderWidth = SpotlightListItemCell.imageBorderWidth
        imageView.layer.borderColor = SpotlightListItemCell.imageBorderColour.cgColor
        imageView.layer.cornerRadius = SpotlightListItemCell.imageCornerRadius
        imageView.clipsToBounds = true
        
        shadowView.clipsToBounds = false

        shadowView.setShadows(
            shadows: SpotlightListItemCell.shadows ?? [SpotlightListItemCell.shadow],
            cornerRadius: SpotlightListItemCell.cornerRadius,
            cornerCurve: .continuous
        )
    }
    
    /// Calculates the size of the spotlight list item for the given spotlight
    ///
    /// - Parameters:
    ///   - spotlight: The spotlight which will be rendered
    ///   - availableSize: The size available for the spotlight to render in
    /// - Returns: The size the spotlight's content will occupy
    public class func size(for spotlight: SpotlightObjectProtocol, constrainedTo availableSize: CGSize) -> CGSize {
        
        guard spotlight.image?.image != nil else {
            return textContentSize(for: spotlight, constrainedTo: availableSize)
        }
        
        let imageAspectRatio = SpotlightListItemCell.imageAspectRatio
        let imageWidth = availableSize.width - SpotlightListItemCell.imageMargins.horizontalSum
        let imageHeight = (imageAspectRatio * imageWidth) + SpotlightListItemCell.imageMargins.verticalSum
        
        let textSize = textContentSize(for: spotlight, constrainedTo: availableSize)
        return CGSize(width: availableSize.width, height: textSize.height + imageHeight)
    }
    
    private class func textContentSize(for spotlight: SpotlightObjectProtocol, constrainedTo availableSize: CGSize) -> CGSize {
        
        var textSizes: [CGSize] = []
        let calculationLabel = SpotlightCollectionViewCell.heightCalculationLabel
        let availableLabelSize = CGSize(width: availableSize.width - SpotlightListItemCell.textContainerPadding.left - SpotlightListItemCell.textContainerPadding.right, height: .greatestFiniteMagnitude)
        calculationLabel.numberOfLines = 0
        
        if let title = spotlight.title ?? spotlight.text, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            
            calculationLabel.text = title
            calculationLabel.textAlignment = SpotlightListItemCell.titleLabelTextAlignment
            calculationLabel.font = ThemeManager.shared.theme.dynamicFont(from: SpotlightListItemCell.titleLabelFontComponents)
            textSizes.append(calculationLabel.sizeThatFits(availableLabelSize))
        }
        
        if let category = spotlight.category, !category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            
            calculationLabel.text = category
            calculationLabel.textAlignment = SpotlightListItemCell.categoryLabelTextAlignment
            calculationLabel.font = ThemeManager.shared.theme.dynamicFont(from: SpotlightListItemCell.categoryLabelFontComponents)
            textSizes.append(calculationLabel.sizeThatFits(availableLabelSize))
            
            // Category label is always shown to maintain height of spotlights
        } else {
            
            // Use non-empty string otherwise we don't get a height!
            calculationLabel.text = " "
            calculationLabel.font = ThemeManager.shared.theme.dynamicFont(from: SpotlightListItemCell.categoryLabelFontComponents)
            textSizes.append(calculationLabel.sizeThatFits(availableLabelSize))
        }
        
        if let description = spotlight.description, !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            
            calculationLabel.text = description
            calculationLabel.textAlignment = SpotlightListItemCell.descriptionLabelTextAlignment
            calculationLabel.font = ThemeManager.shared.theme.dynamicFont(from: SpotlightListItemCell.descriptionLabelFontComponents)
            textSizes.append(calculationLabel.sizeThatFits(availableLabelSize))
        }
        
        guard !textSizes.isEmpty else { return .zero }
        
        var height = textSizes.reduce(0.0, { (result, size) -> CGFloat in
            return result + size.height
        })
        height += max(0, CGFloat((textSizes.count - 1)) * SpotlightListItemCell.textContainerSpacing)
        
        return CGSize(width: availableLabelSize.width, height: height + SpotlightListItemCell.textContainerPadding.top + SpotlightListItemCell.textContainerPadding.bottom)
    }
    
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // Override this otherwise a click on the "empty space" below the cell triggers cell selection
        return shadowView.point(inside: point, with: event)
    }
    
    public override var isAccessibilityElement: Bool {
        get {
            return false
        }
        set { }
    }
}

public protocol SpotlightListItemCellDelegate: class {
    func spotlightCell(cell: SpotlightListItemCell, didReceiveTapOnItem atIndex: Int)
}

open class SpotlightListItemCell: StormTableViewCell, ScrollOffsetManagable {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    @IBOutlet private weak var pageIndicator: UIPageControl!
    
    @IBOutlet weak var spotlightHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pageIndicatorBottomConstraint: NSLayoutConstraint!
    
    /// The space between the page indicator and the bottom of the cell
    public static func bottomMargin(pageIndicatorShown: Bool) -> CGFloat {
        return pageIndicatorShown ? 16.0 : 12.0
    }
    
    /// The spacing between spotlights in the cell
    public static var itemSpacing: CGFloat = 12.0
    
    /// The image aspect ratio for items in the spotlight
    public static var imageAspectRatio: CGFloat = 133.0/330.0
    
    /// UIFont components for the category label on an individual spotlight
    public static var categoryLabelFontComponents: UIFont.Components = .init(
        size: 10,
        textStyle: .footnote,
        weight: .semibold
    )

    /// The text alignment for the category label on an individual spotlight
    public static var categoryLabelTextAlignment: NSTextAlignment = .natural

    /// UIFont components for the title label on an individual spotlight
    public static var titleLabelFontComponents: UIFont.Components = .init(
        size: 20,
        textStyle: .title2,
        weight: .bold
    )

    /// The text alignment for the title label on an individual spotlight
    public static var titleLabelTextAlignment: NSTextAlignment = .natural
    
    /// UIFont components for the description label on an individual spotlight
    public static var descriptionLabelFontComponents: UIFont.Components = .init(
        size: 13,
        textStyle: .subheadline
    )

    /// The text alignment for the description label on an individual spotlight
    public static var descriptionLabelTextAlignment: NSTextAlignment = .natural
    
    /// Padding of the text container below the spotlight's image view
    public static var textContainerPadding = UIEdgeInsets(top: 7, left: 14, bottom: 12, right: 14)
    
    /// Spacing of the labels in `labelsStackView` of spotlight cell
    public static var textContainerSpacing: CGFloat = 0
    
    /// Corner radius of an individual spotlight
    public static var borderWidth: CGFloat = 1.0/UIScreen.main.scale
    
    /// Corner radius of an individual spotlight
    public static var cornerRadius: CGFloat = 12.0

    /// Selected page indicator colour for UIPageIndicator
    public static var pageIndicatorColour: UIColor = .black

    /// Border width of the image on the spotlight
    public static var imageBorderWidth: CGFloat = 1.0/UIScreen.main.scale

    /// Border colour of the image on the spotlight
    public static var imageBorderColour: UIColor = .clear

    /// Corner radius of the image view within an individual spotlight
    public static var imageCornerRadius: CGFloat = 0.0

    /// The margins surrounding the image view within an individual spotlight
    public static var imageMargins: UIEdgeInsets = .zero

    /// The shadow style of an individual spotlight
    /// if `shadows` is set, will override this property
    public static var shadow: ShadowComponents = .init(
        radius: 15.0,
        opacity: 0.5,
        color: UIColor(
            red: 212.0/255.0,
            green: 212.0/255.0,
            blue: 212.0/255.0,
            alpha: 1.0
        ),
        offset: .zero
    )
    
    /// The shadow styles of an individual spotlight
    public static var shadows: [ShadowComponents]?

    weak var delegate: SpotlightListItemCellDelegate?
    
    var currentPage: Int = 0 {
        didSet {
            pageIndicator.currentPage = currentPage
        }
    }
    
    var spotlights: [SpotlightObjectProtocol]? {
        didSet {
            
            if let spotLights = spotlights {
                pageIndicator.isHidden = spotLights.count < 2
            }
            pageIndicator.numberOfPages = spotlights?.count ?? 0
            collectionView.reloadData()
        }
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        commonSetup()
    }
    
    private func commonSetup() {
        
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset = .zero
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing = .zero
        
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds = false
        collectionView.decelerationRate = .fast
        
        collectionView.isAccessibilityElement = false
        collectionView.shouldGroupAccessibilityChildren = true
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.scrollsToTop = false
        collectionView.isPagingEnabled = true
        let nib = UINib(nibName: "SpotlightCollectionViewCell", bundle: Bundle(for: SpotlightListItemCell.self))
        collectionView.register(nib, forCellWithReuseIdentifier: "SpotlightCell")
        
        pageIndicator.currentPageIndicatorTintColor = SpotlightListItemCell.pageIndicatorColour
        pageIndicator.pageIndicatorTintColor = ThemeManager.shared.theme.grayColor
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    @IBAction func handlePageControl(_ sender: UIPageControl) {
        
        guard let spotlights = spotlights, spotlights.indices.contains(sender.currentPage) else { return }
        
        collectionView.scrollToItem(at: IndexPath(item: sender.currentPage, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    open func configure(spotlightCell: SpotlightCollectionViewCell, with spotlight: SpotlightObjectProtocol) {
        
        spotlightCell.imageView.image = spotlight.image?.image
        spotlightCell.imageView.accessibilityLabel = spotlight.image?.accessibilityLabel
        spotlightCell.imageView.isAccessibilityElement = spotlight.image?.accessibilityLabel != nil
        spotlightCell.imageView.isHidden = spotlight.image?.image == nil
        spotlightCell.clipsToBounds = false
        spotlightCell.contentView.clipsToBounds = false
        spotlightCell.imageView.clipsToBounds = true

        if let link = spotlight.link {
            spotlightCell.accessibilityTraits = link.accessibilityTraits
            spotlightCell.accessibilityHint = link.accessibilityHint
        } else {
            spotlightCell.accessibilityTraits = []
            spotlightCell.accessibilityHint = nil
        }
        
        if spotlight.image?.image != nil {
            let imageAspect = SpotlightListItemCell.imageAspectRatio
            let imageHeight = imageAspect * (spotlightCell.bounds.width
                                                - SpotlightListItemCell.imageMargins.horizontalSum
                                                - SpotlightListItemCell.itemSpacing * 2
                                            )
            spotlightCell.imageHeightConstraint.constant = imageHeight
            spotlightCell.imageTopConstraint.constant = SpotlightListItemCell.imageMargins.top
            spotlightCell.imageTrailingConstraint.constant = SpotlightListItemCell.imageMargins.right
            spotlightCell.imageBottomConstraint.constant = SpotlightListItemCell.imageMargins.bottom
            spotlightCell.imageLeadingConstraint.constant = SpotlightListItemCell.imageMargins.left
        } else {
            spotlightCell.imageHeightConstraint.constant = 0.0
            spotlightCell.imageTopConstraint.constant = 0.0
            spotlightCell.imageTrailingConstraint.constant = 0.0
            spotlightCell.imageBottomConstraint.constant = 0.0
            spotlightCell.imageLeadingConstraint.constant = 0.0
        }

        spotlightCell.titleLabel.textAlignment = SpotlightListItemCell.titleLabelTextAlignment
        spotlightCell.titleLabel.font = ThemeManager.shared.theme.dynamicFont(from: SpotlightListItemCell.titleLabelFontComponents)
        spotlightCell.titleLabel.textColor = ThemeManager.shared.theme.cellTitleColor
        
        if let title = spotlight.title ?? spotlight.text, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            
            spotlightCell.titleLabel.isHidden = false
            spotlightCell.titleLabel.text = title

        } else {
            
            spotlightCell.titleLabel.isHidden = true
            spotlightCell.titleLabel.text = nil
        }
        
        let contentInsets = SpotlightListItemCell.textContainerPadding
        spotlightCell.contentTopConstraint.constant = contentInsets.top
        spotlightCell.contentLeadingConstraint.constant = contentInsets.left
        spotlightCell.contentTrailingConstraint.constant = contentInsets.right
        spotlightCell.contentBottomConstraint.constant = contentInsets.bottom
        
        spotlightCell.labelsStackView.spacing = SpotlightListItemCell.textContainerSpacing

        spotlightCell.categoryLabel.textAlignment = SpotlightListItemCell.categoryLabelTextAlignment
        spotlightCell.categoryLabel.textColor = ThemeManager.shared.theme.darkGrayColor
        spotlightCell.categoryLabel.font = ThemeManager.shared.theme.dynamicFont(from: SpotlightListItemCell.categoryLabelFontComponents)
        
        // Keep track of this because of our sneaky hack of not actually hiding the category label when it has empty text
        var categoryHidden: Bool = false
        
        if let category = spotlight.category, !category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            
            spotlightCell.categoryLabel.alpha = 1.0
            spotlightCell.categoryLabel.text = category
            
        } else {
            
            // Give it some text so it retains it's height and title label is always aligned properly
            categoryHidden = true
            spotlightCell.categoryLabel.text = "  "
            spotlightCell.categoryLabel.alpha = 0.0
        }

        spotlightCell.descriptionLabel.textColor = ThemeManager.shared.theme.darkGrayColor
        spotlightCell.descriptionLabel.font = ThemeManager.shared.theme.dynamicFont(from: SpotlightListItemCell.descriptionLabelFontComponents)
        spotlightCell.descriptionLabel.textAlignment = SpotlightListItemCell.descriptionLabelTextAlignment
        
        if let description = spotlight.description, !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            
            spotlightCell.descriptionLabel.isHidden = false
            spotlightCell.descriptionLabel.text = description

        } else {
            
            spotlightCell.descriptionLabel.isHidden = true
            spotlightCell.descriptionLabel.text = nil
        }
        
        spotlightCell.titleContainerView.isHidden = spotlightCell.titleLabel.isHidden && categoryHidden && spotlightCell.descriptionLabel.isHidden
    }
    
    //MARK: - ScrollOffsetManagable
    
    public weak var scrollDelegate: ScrollOffsetDelegate?
    
    public var identifier: AnyHashable?
    
    public var scrollView: UIScrollView? {
        return collectionView
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let pageWidth = scrollView.bounds.width
        let page = (scrollView.contentOffset.x + scrollView.contentInset.left) / pageWidth
        
        currentPage = Int(round(page))
        
        scrollDelegate?.scrollViewDidChangeContentOffset(self)
    }
    
    //MARK: - Accessibility
    
    var carouselAccessibilityElement: CarouselAccessibilityElement?
    
    // We need to cache `accessibilityElements`. See apple example for an explanation why.
    private var _accessibilityElements: [Any]?

    override open var accessibilityElements: [Any]? {
        set {
            _accessibilityElements = newValue
        }
        get {
            guard _accessibilityElements == nil else {
                return _accessibilityElements
            }

            let carouselAccessibilityElement: CarouselAccessibilityElement
            if let theCarouselAccessibilityElement = self.carouselAccessibilityElement {
                carouselAccessibilityElement = theCarouselAccessibilityElement
            } else {
                carouselAccessibilityElement = CarouselAccessibilityElement(
                    accessibilityContainer: self,
                    dataSource: self
                )
                carouselAccessibilityElement.currentElement = currentPage
                carouselAccessibilityElement.accessibilityLabel = "Spotlight".localised(with: "_SPOTLIGHT_ACCESSIBILITY_LABEL")
                carouselAccessibilityElement.accessibilityFrameInContainerSpace = collectionView.frame
                self.carouselAccessibilityElement = carouselAccessibilityElement
            }

            _accessibilityElements = [carouselAccessibilityElement]

            return _accessibilityElements
        }
    }
}

extension SpotlightListItemCell: CarouselAccessibilityElementDataSource {
    
    public func carouselAccessibilityElement(_ element: CarouselAccessibilityElement, accessibilityTraitsForItemAt index: Int) -> UIAccessibilityTraits {
        guard let spotlights = spotlights, index < spotlights.count else {
            return [.adjustable]
        }
        let spotlight = spotlights[index]
        return spotlight.link != nil ? [.adjustable, .button] : [.adjustable]
    }
    
    public func carouselAccessibilityElement(_ element: CarouselAccessibilityElement, accessibilityValueAt index: Int) -> String? {
        
        guard let visibleCell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? SpotlightCollectionViewCell else { return nil }
        
        return [visibleCell.imageView?.accessibilityLabel, visibleCell.categoryLabel.text, visibleCell.titleLabel.text, visibleCell.descriptionLabel.text].compactMap({ $0 }).filter({ !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }).joined(separator: ",")
    }
    
    public func carouselAccessibilityElement(_ element: CarouselAccessibilityElement, scrollToItemAt index: Int, announce: Bool) {
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
        let ofAnnnouncement = "{INDEX} of {COUNT}".localised(
            with: "_SPOTLIGHT_ACCESSIBILITY_INDEXCHANGEDANNOUNCEMENT",
            paramDictionary: [
                "INDEX": "\(index + 1)",
                "COUNT": "\(pageIndicator.numberOfPages)"
            ]
        )
        UIAccessibility.post(notification: .pageScrolled, argument: ofAnnnouncement)
    }
    
    public func numberOfItems(in element: CarouselAccessibilityElement) -> Int {
        return pageIndicator.numberOfPages
    }
}

//MARK: UICollectionViewDelegateFlowLayout methods
extension SpotlightListItemCell: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: bounds.size.width, height: collectionView.bounds.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.spotlightCell(cell: self, didReceiveTapOnItem: indexPath.item)
    }
}

//MARK: UICollectionViewDataSource methods
extension SpotlightListItemCell: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return spotlights?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpotlightCell", for: indexPath)
        
        guard let spotlightCell = cell as? SpotlightCollectionViewCell, let spotlight = spotlights?[indexPath.item] else {
            return cell
        }
        
        configure(spotlightCell: spotlightCell, with: spotlight)
        
        return spotlightCell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

//MARK: UIScrollViewDelegate methods
extension SpotlightListItemCell: UIScrollViewDelegate {
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageWidth = scrollView.bounds.width
        let page = (scrollView.contentOffset.x + scrollView.contentInset.left) / pageWidth
        
        currentPage = Int(round(page))
    }
}
