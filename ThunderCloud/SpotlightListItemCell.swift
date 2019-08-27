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

public class CarouselCollectionViewLayout: UICollectionViewFlowLayout {
    
    public override var itemSize: CGSize {
        get {
            return CGSize(
                width: (collectionView?.bounds.width ?? UIScreen.main.bounds.width) -
                    (2 * SpotlightListItemCell.itemOverhang) -
                    (2 * SpotlightListItemCell.itemSpacing),
                height: collectionView?.bounds.height ?? 0
            )
        }
        set { }
    }
    
    override public func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        guard let collectionView = self.collectionView else {
            let latestOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
            return latestOffset
        }
        
        // Page width used for estimating and calculating paging.
        let pageWidth = itemSize.width + minimumLineSpacing
        
        // Make an estimation of the current page position.
        let approximatePage = collectionView.contentOffset.x/pageWidth
        
        // Determine the current page based on velocity.
        let currentPage = velocity.x == 0 ? round(approximatePage) : (velocity.x < 0.0 ? floor(approximatePage) : ceil(approximatePage))
        
        // Create custom flickVelocity.
        let flickVelocity = velocity.x * 0.3
        
        // Check how many pages the user flicked, if <= 1 then flickedPages should return 0.
        let flickedPages = (abs(round(flickVelocity)) <= 1) ? 0 : round(flickVelocity)
        
        // Calculate newHorizontalOffset.
        let newHorizontalOffset = ((currentPage + flickedPages) * pageWidth) - collectionView.contentInset.left
        
        return CGPoint(x: newHorizontalOffset, y: proposedContentOffset.y)
    }
}

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
    public class func size(for spotlight: Spotlight, constrainedTo availableSize: CGSize) -> CGSize {
        
        guard spotlight.image?.image != nil else {
            return textContentSize(for: spotlight, constrainedTo: availableSize)
        }
        
        let imageAspectRatio = SpotlightListItemCell.imageAspectRatio
        let imageHeight = imageAspectRatio * availableSize.width
        
        let textSize = textContentSize(for: spotlight, constrainedTo: availableSize)
        return CGSize(width: availableSize.width, height: textSize.height + imageHeight)
    }
    
    private class func textContentSize(for spotlight: Spotlight, constrainedTo availableSize: CGSize) -> CGSize {
        
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
}

public protocol SpotlightListItemCellDelegate: class {
    func spotlightCell(cell: SpotlightListItemCell, didReceiveTapOnItem atIndex: Int)
}

open class SpotlightListItemCell: StormTableViewCell {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    @IBOutlet private weak var pageIndicator: UIPageControl!
    
    @IBOutlet weak var spotlightHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pageIndicatorBottomConstraint: NSLayoutConstraint!
    
    /// The space between the spotlight collection view and it's nearest items
    public static let collectionMargins = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
    
    /// The space between the page indicator and the bottom of the cell
    public static let bottomMargin: CGFloat = 16.0
    
    /// The spacing between spotlights in the cell
    public static let itemSpacing: CGFloat = 10.0
    
    /// The amount of the next and previous spotlight that should overhang the edge of the screen
    public static let itemOverhang: CGFloat = 32.0
    
    /// The image aspect ratio for items in the spotlight
    public static let imageAspectRatio: CGFloat = 133.0/330.0
    
    weak var delegate: SpotlightListItemCellDelegate?
    
    var currentPage: Int = 0 {
        didSet {
            pageIndicator.currentPage = currentPage
        }
    }
    
    var spotlights: [Spotlight]? {
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
        
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset = UIEdgeInsets(top: 0, left: SpotlightListItemCell.itemSpacing + SpotlightListItemCell.itemOverhang, bottom: 0, right: SpotlightListItemCell.itemSpacing + SpotlightListItemCell.itemOverhang)
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing = SpotlightListItemCell.itemSpacing
        
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds = false
        collectionView.decelerationRate = .fast
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.scrollsToTop = false
        collectionView.isPagingEnabled = false
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
    
    open func configure(spotlightCell: SpotlightCollectionViewCell, with spotlight: Spotlight) {
        
        spotlightCell.imageView.image = spotlight.image?.image
        spotlightCell.imageView.accessibilityLabel = spotlight.image?.accessibilityLabel
        spotlightCell.imageView.isHidden = spotlight.image?.image == nil
        spotlightCell.clipsToBounds = false
        spotlightCell.contentView.clipsToBounds = false
        
        if spotlight.image?.image != nil {
            let imageAspect = SpotlightListItemCell.imageAspectRatio
            let imageHeight = imageAspect * spotlightCell.bounds.width
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
        }
        
        spotlightCell.titleContainerView.isHidden = spotlightCell.titleLabel.isHidden && categoryHidden && spotlightCell.descriptionLabel.isHidden
    }
}

//MARK: UICollectionViewDelegateFlowLayout methods
extension SpotlightListItemCell: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = bounds.size.width - (2 * SpotlightListItemCell.itemSpacing) - (2 * SpotlightListItemCell.itemOverhang)
        return CGSize(width: availableWidth, height: collectionView.bounds.height)
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
        return SpotlightListItemCell.itemSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

//MARK: UIScrollViewDelegate methods
extension SpotlightListItemCell: UIScrollViewDelegate {
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageWidth = scrollView.bounds.width - (SpotlightListItemCell.itemOverhang * 2) - (SpotlightListItemCell.itemSpacing * 2)
        let page = (scrollView.contentOffset.x + scrollView.contentInset.left) / pageWidth
        
        currentPage = Int(round(page))
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let pageWidth = scrollView.bounds.width - (SpotlightListItemCell.itemOverhang * 2) - (SpotlightListItemCell.itemSpacing * 2)
        let page = (scrollView.contentOffset.x + scrollView.contentInset.left) / pageWidth
        
        currentPage = Int(round(page))
    }
}
