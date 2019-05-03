//
//  LinkCollectionViewCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 03/05/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import UIKit

/// A subclass of `UICollectionViewCell` for displaying in a storm link scroller
class LinkScrollerCollectionViewCell: UICollectionViewCell {
    
    /// The image view to display the link's image in
    let imageView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.contentMode = .center
        contentView.addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = CGRect(x: 0, y: 0, width: 57, height: 57)
        imageView.center = contentView.center
    }
}
