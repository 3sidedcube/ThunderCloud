//
//  AccessibleCollectionView.swift
//  First Aid 2.0
//
//  Created by Simon Mitchell on 04/09/2019.
//  Copyright © 2019 3 SIDED CUBE. All rights reserved.
//

import UIKit

/// A subclass of `UICollectionViewCell` that can be used in `UITableViewCell`
/// and returns the correct value from `accessibilityElementCount()`
public class AccessibleCollectionView: UICollectionView {

    override open func accessibilityElementCount() -> Int {
        
        guard let dataSource = dataSource else {
            return 0
        }
        
        let numberOfSections = dataSource.numberOfSections?(in: self) ?? 0
        var count = 0
        
        for section in 0..<numberOfSections {
            count += dataSource.collectionView(self, numberOfItemsInSection: section)
        }
        
        return count
    }
}
