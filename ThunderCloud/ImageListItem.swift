//
//  ImageListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 05/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// A subclass of `ListItem` which displays an image in the table row at it's original aspect ratio
open class ImageListItem: ListItem {
    
    override open var cellClass: UITableViewCell.Type? {
        return TableImageViewCell.self
    }
    
    override open var image: UIImage? {
        get {
            if super.image == nil {
                
                let bundle = Bundle(for: ImageListItem.self)
                let transparentImage = UIImage(named: "transparent", in: bundle, compatibleWith: nil)
                return transparentImage?.resizableImage(withCapInsets: .zero, resizingMode: .tile)
            }
            
            return super.image
        }
        set {
            super.image = newValue
        }
    }
    
    override open var estimatedHeight: CGFloat? {
        return imageHeight(constrainedTo: UIScreen.main.bounds.width)
    }
    
    open func imageHeight(constrainedTo width: CGFloat) -> CGFloat? {
        guard let image = image else { return nil }
        let aspectRatio = image.size.height / image.size.width
        return aspectRatio * width
    }
    
    override open func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        
        super.configure(cell: cell, at: indexPath, in: tableViewController)
        
        guard let imageCell = cell as? TableImageViewCell else { return }
        imageCell.cellImageView?.contentMode = .scaleAspectFill
        imageCell.cellImageView?.accessibilityLabel = stormImage?.accessibilityLabel
        imageCell.layer.masksToBounds = true
        
        if let imageHeight = imageHeight(constrainedTo: tableViewController.view.frame.width) {
            imageCell.imageHeightConstraint?.constant = imageHeight
        }
    }
    
    override open var accessoryType: UITableViewCell.AccessoryType? {
        get {
            return UITableViewCell.AccessoryType.none
        }
        set {}
    }
    
    override open var selectionStyle: UITableViewCell.SelectionStyle? {
        return UITableViewCell.SelectionStyle.none
    }
}
