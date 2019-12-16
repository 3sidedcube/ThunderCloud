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
    
    static let textContainerPadding = UIEdgeInsets(top: 7, left: 14, bottom: 12, right: 14)
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        shadowView.cornerRadius = 12
        containerView.cornerRadius = 12
        containerView.borderWidth = 1.0/UIScreen.main.scale
        containerView.borderColor = UIColor(white: 0.761, alpha: 1.0)
        
        imageView.borderWidth = 1.0/UIScreen.main.scale
        imageView.borderColor = UIColor(white: 0.761, alpha: 1.0)
        
        shadowView.clipsToBounds = false
        
        shadowView.shadowRadius = 15.0
        shadowView.shadowOpacity = 0.5
        shadowView.shadowColor = UIColor(red: 212.0/255.0, green: 212.0/255.0, blue: 212.0/255.0, alpha: 1.0)
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
        let imageHeight = imageAspectRatio * availableSize.width
        
        let textSize = textContentSize(for: spotlight, constrainedTo: availableSize)
        return CGSize(width: availableSize.width, height: textSize.height + imageHeight)
    }
    
    private class func textContentSize(for spotlight: SpotlightObjectProtocol, constrainedTo availableSize: CGSize) -> CGSize {
        
        var textSizes: [CGSize] = []
        let calculationLabel = SpotlightCollectionViewCell.heightCalculationLabel
        let availableLabelSize = CGSize(width: availableSize.width - SpotlightCollectionViewCell.textContainerPadding.left - SpotlightCollectionViewCell.textContainerPadding.right, height: .greatestFiniteMagnitude)
        calculationLabel.numberOfLines = 0
        
        if let title = spotlight.title ?? spotlight.text, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            
            calculationLabel.text = title
            calculationLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 20, textStyle: .title2, weight: .bold)
            textSizes.append(calculationLabel.sizeThatFits(availableLabelSize))
        }
        
        if let category = spotlight.category, !category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            
            calculationLabel.text = category
            calculationLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 10, textStyle: .footnote, weight: .semibold)
            textSizes.append(calculationLabel.sizeThatFits(availableLabelSize))
            
            // Category label is always shown to maintain height of spotlights
        } else {
            
            // Use non-empty string otherwise we don't get a height!
            calculationLabel.text = " "
            calculationLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 10, textStyle: .footnote, weight: .semibold)
            textSizes.append(calculationLabel.sizeThatFits(availableLabelSize))
        }
        
        if let description = spotlight.description, !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            
            calculationLabel.text = description
            calculationLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 13, textStyle: .subheadline)
            textSizes.append(calculationLabel.sizeThatFits(availableLabelSize))
        }
        
        guard !textSizes.isEmpty else { return .zero }
        
        let height = textSizes.reduce(0.0, { (result, size) -> CGFloat in
            return result + size.height
        })
        
        return CGSize(width: availableLabelSize.width, height: height + SpotlightCollectionViewCell.textContainerPadding.top + SpotlightCollectionViewCell.textContainerPadding.bottom)
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

open class SpotlightListItemCell: StormTableViewCell {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    @IBOutlet private weak var pageIndicator: UIPageControl!
    
    @IBOutlet weak var spotlightHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pageIndicatorBottomConstraint: NSLayoutConstraint!
    
    /// The space between the page indicator and the bottom of the cell
    public static func bottomMargin(pageIndicatorShown: Bool) -> CGFloat {
        return pageIndicatorShown ? 16.0 : 12.0
    }
    
    /// The spacing between spotlights in the cell
    public static let itemSpacing: CGFloat = 12.0
    
    /// The image aspect ratio for items in the spotlight
    public static let imageAspectRatio: CGFloat = 133.0/330.0
    
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
        
        pageIndicator.currentPageIndicatorTintColor = .black
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
        
        if spotlight.image?.image != nil {
            let imageAspect = SpotlightListItemCell.imageAspectRatio
            let imageHeight = imageAspect * (spotlightCell.bounds.width - SpotlightListItemCell.itemSpacing * 2)
            spotlightCell.imageHeightConstraint.constant = imageHeight
        } else {
            spotlightCell.imageHeightConstraint.constant = 0.0
        }
        
        if let title = spotlight.title ?? spotlight.text, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            
            spotlightCell.titleLabel.isHidden = false
            spotlightCell.titleLabel.text = title
            spotlightCell.titleLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 20, textStyle: .title2, weight: .bold)
            spotlightCell.titleLabel.textColor = ThemeManager.shared.theme.cellTitleColor
            
        } else {
            
            spotlightCell.titleLabel.isHidden = true
            spotlightCell.titleLabel.text = nil
        }
        
        spotlightCell.categoryLabel.textColor = ThemeManager.shared.theme.darkGrayColor
        spotlightCell.categoryLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 10, textStyle: .footnote, weight: .semibold)
        
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
        
        if let description = spotlight.description, !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            
            spotlightCell.descriptionLabel.isHidden = false
            spotlightCell.descriptionLabel.text = description
            spotlightCell.descriptionLabel.textColor = ThemeManager.shared.theme.darkGrayColor
            spotlightCell.descriptionLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 13, textStyle: .subheadline)
            
        } else {
            
            spotlightCell.descriptionLabel.isHidden = true
            spotlightCell.descriptionLabel.text = nil
        }
        
        spotlightCell.titleContainerView.isHidden = spotlightCell.titleLabel.isHidden && categoryHidden && spotlightCell.descriptionLabel.isHidden
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
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let pageWidth = scrollView.bounds.width
        let page = (scrollView.contentOffset.x + scrollView.contentInset.left) / pageWidth
        
        currentPage = Int(round(page))
    }
}
