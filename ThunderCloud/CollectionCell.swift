//
//  CollectionCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 30/06/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation
import ThunderTable

/// A subclass of `StormTableViewCell` which displays the user a collection view
open class CollectionCell: StormTableViewCell {
	
	/// The collection view used to display the list of items
	@IBOutlet public var collectionView: UICollectionView!
	
	/// The `UICollectionViewFlowLayout` of the cells collection view
	open var collectionViewLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
	
	/// Reloads the collection view of the TSCCollectionCell
	@objc open func reload() {
		collectionView.reloadData()
	}
	
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		collectionViewLayout.scrollDirection = .horizontal
		
		collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
		contentView.addSubview(collectionView)
		
		sharedInit()
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
		collectionView.isPagingEnabled = true
		collectionView.showsHorizontalScrollIndicator = false
	}
	
	override open func layoutSubviews() {
		
		super.layoutSubviews()
		
		if !nibBased {
			collectionView.frame = bounds
		}
	}
}

extension CollectionCell : UICollectionViewDelegateFlowLayout {
	
}

extension CollectionCell : UICollectionViewDataSource {
	
	open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 0
	}
	
	open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		return collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
	}
}
