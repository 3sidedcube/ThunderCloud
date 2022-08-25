//
//  UIPageIndicator+CustomImages.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 11/11/2021.
//  Copyright © 2021 threesidedcube. All rights reserved.
//

import UIKit

extension UIPageControl {

    /// Call to redraw `UIPageControl` images when the selected page changes.
    /// This allows a custom image just for the selected page of the control
    /// - Parameters:
    ///   - unselectedImage: Unselected indicator image
    ///   - selectedImage: Selected indicator image
    func redrawPageIndicatorImagesWith(
        unselected unselectedImage: UIImage?,
        selected selectedImage: UIImage?
    ) {
        if #available(iOS 14, *) {
            for i in 0..<numberOfPages {
                setIndicatorImage(i == currentPage ? selectedImage : unselectedImage, forPage: i)
            }
        }
    }
}
