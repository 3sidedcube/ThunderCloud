//
//  AccessibleCollectionView.swift
//  First Aid 2.0
//
//  Created by Simon Mitchell on 04/09/2019.
//  Copyright © 2019 3 SIDED CUBE. All rights reserved.
//

import UIKit

class AccessibleCollectionView: UICollectionView {

    override func accessibilityElementCount() -> Int {
        
        guard let dataSource = dataSource else {
            return 0
        }
        
        let numberOfSections = dataSource.numberOfSections?(in: self) ?? 1
        var count = 0
        
        for section in 0..<numberOfSections {
            count += dataSource.collectionView(self, numberOfItemsInSection: section)
        }
        
        return count
    }
}
