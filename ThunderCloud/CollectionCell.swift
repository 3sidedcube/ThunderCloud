//
//  CollectionCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 30/06/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation
import ThunderTable

/// An entity that can be achieved at a `Date` and is valid for a given number of `Int` days.
public struct ExpirableAchievement {

    /// Number of seconds in a day
    private static let secondsInDay: TimeInterval = 60 * 60 * 24
    
    /// Date the achievement was earned
    public var dateEarned: Date
    
    /// How long, in days, the achivement is valid for after the `dateEarned`
    public var validFor: Int
    
    /// Public memberwise initialization
    public init (dateEarned: Date, validFor: Int) {
        self.dateEarned = dateEarned
        self.validFor = validFor
    }
    
    /// How long, in seconds, the achivement is valid for after the `dateEarned`
    public var validForSeconds: TimeInterval {
        return ExpirableAchievement.secondsInDay * TimeInterval(validFor)
    }
    
    /// Date the achivement expires
    public var expiryDate: Date {
        return dateEarned.addingTimeInterval(validForSeconds)
    }
    
    /// Has the achievement expired
    public var hasExpired: Bool {
        return Date() > expiryDate
    }
    
    /// How far along are we in the range [0, 1] are we to expiring.
    /// Close to 1 -> close to expired
    /// Close to 0 -> far from expired
    /// So over time progress will converge to 1
    public var timeProgress: Float {
        let now = Date()
        let secondsSinceDateEarned = now.timeIntervalSince(dateEarned)
        let secondsValidFor = validForSeconds
        
        guard secondsValidFor > 0 else {
            return 0
        }
        
        let timeProgress = Float(secondsSinceDateEarned/secondsValidFor)
        return bounded(timeProgress, lower: 0, upper: 1)
    }
    
    /// Reflection of `timeProgress` about the middle point.
    /// How far along are we in the range [0, 1] are we to being fully degraded.
    /// Close to 0 -> Almost fully degraded
    /// Close to 1 -> Barely degraded
    /// So over time progress will converge to 0
    public var progress: Float {
        return 1 - timeProgress
    }
    
    /// Local date string for `expiryDate`
    var expiryDateString: String {
        return DateFormatter.localDate.string(from: expiryDate)
    }
}

/// A protocol which can be conformed to in order to be displayed in a `CollectionCell`
public protocol CollectionCellDisplayable {
    
    /// The item's image
    var itemImage: StormImage? { get }
    
    /// The item's title
    var itemTitle: String? { get }
    
    /// Whether the item should be rendered as selected
    var enabled: Bool { get }
    
    /// The item's accessibility label
    var accessibilityLabel: String? { get }
    
    /// The item's accessibility hint
    var accessibilityHint: String? { get }
    
    /// The item's accessibility traits
    var accessibilityTraits: UIAccessibilityTraits { get }
    
    /// Does the item degrade over time
    var expirableAchievement: ExpirableAchievement? { get }
}

public extension CollectionCellDisplayable {
    
    /// Provide default implmentation for `expirableAchievement`
    var expirableAchievement: ExpirableAchievement? {
        return nil
    }
}

/// A subclass of `StormTableViewCell` which displays the user a collection view
open class CollectionCell: StormTableViewCell, ScrollOffsetManagable {
    
    
    /// The items that are displayed in the collection cell
    public var items: [CollectionCellDisplayable]? {
        didSet {
            reload()
        }
    }

	/// The collection view used to display the list of items
	@IBOutlet public var collectionView: UICollectionView!
	
	/// The `UICollectionViewFlowLayout` of the cells collection view
	open var collectionViewLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
	
	/// Reloads the collection view of the TSCCollectionCell
	@objc open func reload() {
		collectionView.reloadData()
	}
    
    /// Nib name for the `UICollectionViewCell` used in `CollectionCell`
    static let CollectionItemViewCellNibName = "CollectionItemViewCell"
	
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.sectionInset = .init(
            top: CollectionItemViewCell.Constants.cellPadding.top,
            left: 0,
            bottom: CollectionItemViewCell.Constants.cellPadding.bottom,
            right: 0
        )
		
		collectionView = AccessibleCollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
		contentView.addSubview(collectionView)
        
        collectionView.isAccessibilityElement = false
        collectionView.shouldGroupAccessibilityChildren = true
		
		sharedInit()
        
        let cellNib = UINib(nibName: CollectionCell.CollectionItemViewCellNibName, bundle: Bundle(for: CollectionCell.self))
        collectionView.register(cellNib, forCellWithReuseIdentifier: CollectionCell.CollectionItemViewCellNibName)
	}
	
	private var nibBased = false
	
	override open func awakeFromNib() {
		super.awakeFromNib()
		sharedInit()
		nibBased = true
	}
	
	required public init?(coder aDecoder: NSCoder) {

		super.init(coder: aDecoder)
		sharedInit()
	}
	
	private func sharedInit() {
        
        guard let collectionView = collectionView else { return }
		
		collectionView.delegate = self
		collectionView.dataSource = self
		collectionView.backgroundColor = .clear
		collectionView.alwaysBounceHorizontal = true
		collectionView.showsHorizontalScrollIndicator = false
	}
	
	override open func layoutSubviews() {
		super.layoutSubviews()
        updateCollectionViewFrame()
	}
    
    /// This method can be overridden by subclasses when the default (non-nib) behavior doesn't apply
    open func updateCollectionViewFrame() {
        if !nibBased {
            collectionView.frame = contentView.bounds
        }
    }
    
    override open var isAccessibilityElement: Bool {
        get {
            return false
        }
        set { }
    }
    
    //MARK: - ScrollOffsetManagable
    
    public var scrollDelegate: ScrollOffsetDelegate?
    
    public var identifier: AnyHashable?
    
    public var scrollView: UIScrollView? {
        return collectionView
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidChangeContentOffset(self)
    }
}

extension CollectionCell : UICollectionViewDelegateFlowLayout {
	
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let items = items, items.indices.contains(indexPath.item) else { return .zero }
        
        let item = items[indexPath.item]
        let size = CollectionItemViewCell.size(for: item, includingVerticalPadding: false)
        return size
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension CollectionCell : UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
	
	open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return items?.count ?? 0
	}
	
	open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionCell.CollectionItemViewCellNibName, for: indexPath)
        guard let items = items, items.indices.contains(indexPath.item), let collectionCell = cell as? CollectionItemViewCell else { return cell }
        let item = items[indexPath.item]
        collectionCell.configure(with: item)
        return collectionCell
	}
}
