//
//  AppCollectionCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import StoreKit

/// A subclass of `CollectionCell` which displays the user a collection of links.
/// Links in this collection view are displayed as their image
class LinkCollectionCell: CollectionCell {
	
	/// The array of links to be shown in the collection view
	var links: [LinkCollectionItem]? {
		didSet {
			reload()
		}
	}
	
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		let cellClass: AnyClass? = StormObjectFactory.shared.class(for: NSStringFromClass(LinkScrollerCollectionViewCell.self))
		collectionView.register(cellClass ?? LinkScrollerCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
		
		pageControl.removeFromSuperview()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}

//MARK: -
//MARK: UICollectionViewDataSource
//MARK: -
extension LinkCollectionCell {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return links?.count ?? 0
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
		guard let links = links, let linkCell = cell as? LinkScrollerCollectionViewCell else { return cell }
		
		let link = links[indexPath.row]
		linkCell.imageView.image = link.image
		
		return linkCell
	}
}

//MARK: -
//MARK: UICollectionViewDelegateFlowLayout
//MARK: -
extension LinkCollectionCell {
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 80, height: bounds.size.height)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		guard let links = links, let link = links[indexPath.item].link else { return }
		parentViewController?.navigationController?.push(link: link)
	}
}
