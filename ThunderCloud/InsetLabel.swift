//
//  InsetLabel.swift
//  GDPC
//
//  Created by Ben Shutt on 21/11/2019.
//  Copyright © 2019 3 SIDED CUBE APP PRODUCTIONS LTD. All rights reserved.
//

import UIKit

open class InsetLabel: UILabel
{
    public var insets = UIEdgeInsets.zero {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    /// Add `cornerRadius` according to the `min(bounds.size.width, bounds.size.height)`
    public var roundCorners = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    // MARK: - View
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        preferredMaxLayoutWidth = frame.width - (insets.left + insets.right)
        
        if roundCorners {
            clipsToBounds = true
            layer.cornerRadius = 0.5 * min(bounds.size.height, bounds.size.width)
        }
    }

    override open func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: insets)
        super.drawText(in: insetRect)
    }

    override open var intrinsicContentSize: CGSize {
        return addInsets(to: super.intrinsicContentSize)
    }

    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        return addInsets(to: super.sizeThatFits(size))
    }
    
    // MARK: - Inset

    private func addInsets(to size: CGSize) -> CGSize {
        let width = size.width + insets.left + insets.right
        let height = size.height + insets.top + insets.bottom
        return CGSize(width: width, height: height)
    }
}
