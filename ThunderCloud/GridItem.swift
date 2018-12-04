//
//  GridItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 16/02/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import UIKit
import ThunderCollection

/// A root class for an item to be displayed in a `grid` or `UICollectionView`
open class GridItem: CollectionItemDisplayable, StormObjectProtocol {
	
	open var cellClass: UICollectionViewCell.Type? {
		return UICollectionViewCell.self
	}
	
	/// A `StormLink` which determines what the item does when it is selected
    public let link: StormLink?
	
	/// The image to be displayed when displaying this item in a `UICollectionView`
	open var image: UIImage?
	
	/// The title to be displayed when displaying this item in a `UICollectionView`
    public let title: String?
	
	/// The description to be displayed when displaying this item in a `UICollectionView`
    public let description: String?
	
	public required init?(dictionary: [AnyHashable : Any]) {
		
		remainSelected = false
		
		if let linkDicationary = dictionary["link"] as? [AnyHashable : Any] {
			link = StormLink(dictionary: linkDicationary)
		} else {
			link = nil
		}
		
		if let titleDict = dictionary["title"] as? [AnyHashable : Any] {
			title = StormLanguageController.shared.string(for: titleDict)
		} else {
			title = nil
		}
		
		if let subtitleDict = dictionary["description"] as? [AnyHashable : Any] {
			description = StormLanguageController.shared.string(for: subtitleDict)
		} else {
			description = nil
		}
		
		image = StormGenerator.image(fromJSON: dictionary["image"])
	}
	
    // This is empty, but must be left here in order for subclasses to implement the method and it still be called
	public func configure(cell: UICollectionViewCell, at indexPath: IndexPath, in collectionViewController: CollectionViewController) {
		
	}

	public var prototypeIdentifier: String? {
		return nil
	}
	
	public var remainSelected: Bool
	
	public func size(constrainedTo size: CGSize, in collectionView: UICollectionView) -> CGSize? {
		return nil
	}
}
