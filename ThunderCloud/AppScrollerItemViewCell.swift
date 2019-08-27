//
//  AppScrollerItemViewCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 03/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// A subclass of `UICollectionViewCell` for displaying an app
open class AppScrollerItemViewCell: UICollectionViewCell {
    
    /// An image view for displaying the app icon
    public let appIconView: UIImageView = UIImageView()
    
    /// A label for displaying the app name
    public let nameLabel: UILabel = UILabel()
    
    /// A label for displaying the app price
    public let priceLabel: UILabel = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(appIconView)
        
        nameLabel.textAlignment = .center
        nameLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 14, textStyle: .footnote)
        contentView.addSubview(nameLabel)
        
        priceLabel.textColor = ThemeManager.shared.theme.secondaryColor
        priceLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 14, textStyle: .footnote)
        priceLabel.numberOfLines = 0
        priceLabel.textAlignment = .center
        contentView.addSubview(priceLabel)
        
        appIconView.contentMode = .redraw
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        appIconView.frame = CGRect(x: 0, y: 8, width: 68, height: 68)
        appIconView.set(centerX: bounds.width/2)
        
        if let priceText = priceLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines), !priceText.isEmpty {
            nameLabel.frame = CGRect(x: 0, y: appIconView.frame.maxY, width: contentView.frame.width, height: 25)
        } else {
            nameLabel.frame = CGRect(x: 0, y: appIconView.frame.maxY + 12, width: contentView.frame.width, height: 25)
        }
        
        priceLabel.sizeToFit()
        priceLabel.set(minY: nameLabel.frame.maxY - 4)
        priceLabel.set(width: nameLabel.frame.width)
        priceLabel.set(centerX: nameLabel.center.x)
    }
}
