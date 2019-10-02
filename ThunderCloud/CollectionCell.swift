//
//  CollectionCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 30/06/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation
import ThunderTable

/// A protocol which can be conformed to in order to be displayed in a `CollectionCell`
public protocol CollectionCellDisplayable {
    
    /// The item's image
    var itemImage: StormImage? { get }
    
    /// The item's title
    var itemTitle: String? { get }
    
    /// Whether the item should be rendered as selected
    var enabled: Bool { get }
}

/// A subclass of `StormTableViewCell` which displays the user a collection view
open class CollectionCell: StormTableViewCell {
    
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
		
		if !nibBased {
			collectionView.frame = bounds
		}
	}
    
    override open var isAccessibilityElement: Bool {
        get {
            return false
        }
        set { }
    }
}

extension CollectionCell : UICollectionViewDelegateFlowLayout {
	
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let items = items, items.indices.contains(indexPath.item) else { return .zero }
        
        let item = items[indexPath.item]
        return CollectionItemViewCell.size(for: item)
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
