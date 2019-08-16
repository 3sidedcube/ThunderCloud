//
//  AppCollectionCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import StoreKit

extension LinkCollectionItem: CollectionCellDisplayable {
    
    public var itemTitle: String? {
        return nil
    }
    
    public var itemImage: UIImage? {
        return image?.image
    }
    
    public var itemImageAccessibilityLabel: String? {
        return image?.accessibilityLabel
    }
    
    public var selected: Bool {
        return false
    }
}

/// A subclass of `CollectionCell` which displays the user a collection of links.
/// Links in this collection view are displayed as their image
open class LinkCollectionCell: CollectionCell {
    
}

//MARK: -
//MARK: UICollectionViewDataSource
//MARK: -
extension LinkCollectionCell {
    
}

//MARK: -
//MARK: UICollectionViewDelegateFlowLayout
//MARK: -
extension LinkCollectionCell {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let links = items as? [LinkCollectionItem], let link = links[indexPath.item].link else { return }
        parentViewController?.navigationController?.push(link: link)
    }
}
