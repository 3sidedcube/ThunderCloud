//
//  SpotlightImageListItemViewCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 03/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// This is a legacy version of `SpotlightImageCollectionViewCell` used by `LegacySpotlightListItemCell`
/// to render non ADA compliant spotlights if clients request them
public class LegacySpotlightImageCollectionViewCell: UICollectionViewCell {
    
    /// The image view for the spotlight
    @IBOutlet public weak var imageView: UIImageView!
    
    /// The label that displays the spotlights title/text property
    @IBOutlet public weak var titleLabel: UILabel!
    
    /// An image view which displays a shadow between the image view and title label for readability
    @IBOutlet public weak var textShadowImageView: UIImageView!
}

/// A legacy protocol for use in the non ADA compliant spotlight legacy override
public protocol LegacySpotlightListItemCellDelegate: class {
    /// Function called when a spotlight is selected in a `LegacySpotlightImageCollectionViewCell`
    ///
    /// - Parameters:
    ///   - cell: The cell which the spotlight item was selected in
    ///   - atIndex: The index of the spotlight item which was selected
    func spotlightCell(cell: LegacySpotlightListItemCell, didReceiveTapOnItem atIndex: Int)
}

/// A legacy version of `SpotlightListItemCell` which is used by `SpotlightListItem` to provide a
/// non ADA compliant override to clients who do not wish yet to update to the new ADA compliant UI
open class LegacySpotlightListItemCell: StormTableViewCell {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    @IBOutlet private weak var pageIndicator: UIPageControl!
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    weak var delegate: LegacySpotlightListItemCellDelegate?
    
    /// The current page that the user has scrolled to
    var currentPage: Int = 0 {
        didSet {
            pageIndicator.currentPage = currentPage
            setSpotlightTimer()
        }
    }
    
    /// The spotlight objects which are to be displayed in the cell
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
    
    open override func prepareForReuse() {
        spotlightCycleTimer?.invalidate()
        spotlightCycleTimer = nil
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        commonSetup()
    }
    
    private func commonSetup() {
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.scrollsToTop = false
        let nib = UINib(nibName: "LegacySpotlightImageCollectionViewCell", bundle: Bundle(for: LegacySpotlightListItemCell.self))
        collectionView.register(nib, forCellWithReuseIdentifier: "SpotlightCell")
        
        pageIndicator.isUserInteractionEnabled = false
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
        setSpotlightTimer()
    }
    
    @IBAction func handlePageControl(_ sender: Any) {
        
    }
    
    private var spotlightCycleTimer: Timer?
    
    private func setSpotlightTimer() {
        
        guard let spotlights = spotlights, spotlights.count > currentPage else {
            return
        }
        
        let delay = currentPage < spotlights.count ? spotlights[currentPage].delay ?? 5 : 5
        
        if delay != 0 {
            spotlightCycleTimer?.invalidate()
            spotlightCycleTimer = Timer.scheduledTimer(timeInterval: TimeInterval(delay), target: self, selector: #selector(cycleSpotlight(timer:)), userInfo: nil, repeats: false)
        }
    }
    
    /// Moves the spotlight to the next page
    ///
    /// - Parameter timer: The timer which triggered the move
    @objc func cycleSpotlight(timer: Timer) {
        guard let spotlights = spotlights, spotlights.count > 0 else {
            return
        }
        
        var nextItem: Int = 0
        
        if currentPage < spotlights.count - 1 {
            nextItem = currentPage + 1
        }
        
        let index = IndexPath(item: nextItem, section: 0)
        collectionView.scrollToItem(at: index, at: .left, animated: true)
        currentPage = nextItem
    }
    
    /// Configures the cell with the given spotlight
    ///
    /// - Parameters:
    ///   - spotlightCell: The cell to style/configure
    ///   - spotlight: The spotlight to populate the cell with
    open func configure(spotlightCell: LegacySpotlightImageCollectionViewCell, with spotlight: SpotlightObjectProtocol) {
        
        spotlightCell.imageView.image = spotlight.image?.image
        spotlightCell.imageView.accessibilityLabel = spotlight.image?.accessibilityLabel
        spotlightCell.imageView.isAccessibilityElement = spotlight.image?.accessibilityLabel != nil
        spotlightCell.titleLabel.text = spotlight.title ?? spotlight.text
        spotlightCell.titleLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 22, textStyle: .title2, weight: .bold)
        spotlightCell.titleLabel.shadowColor = UIColor.black.withAlphaComponent(0.5)
        spotlightCell.titleLabel.shadowOffset = CGSize(width: 0, height: 1)
        
        spotlightCell.textShadowImageView.isHidden = spotlightCell.titleLabel.text == nil || spotlightCell.titleLabel.text!.isEmpty
    }
}

//MARK: UICollectionViewDelegateFlowLayout methods
extension LegacySpotlightListItemCell: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: bounds.size.width, height: bounds.size.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.spotlightCell(cell: self, didReceiveTapOnItem: indexPath.item)
    }
}

//MARK: UICollectionViewDataSource methods
extension LegacySpotlightListItemCell: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return spotlights?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpotlightCell", for: indexPath)
        
        guard let spotlightCell = cell as? LegacySpotlightImageCollectionViewCell, let spotlight = spotlights?[indexPath.item] else {
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
extension LegacySpotlightListItemCell: UIScrollViewDelegate {
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let page = scrollView.contentOffset.x / scrollView.frame.width
        currentPage = Int(page)
    }
}
