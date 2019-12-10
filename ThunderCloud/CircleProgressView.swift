//
//  CircleView.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 05/12/2019.
//  Copyright © 2019 BenShutt. All rights reserved.
//

import UIKit

/// Circular `UIView` which strokes a `progressPath` on a `backgroundPath`.
open class CircleProgressView: UIView {
    
    /// `CircleProgressLayer` `progress`.
    public var progress: CGFloat {
        get {
            return circleProgressLayer.progress
        }
        set {
            circleProgressLayer.progress = newValue
        }
    }
    
    // MARK: - Layer

    /// `layerClass` as `CircleProgressLayer`
    public var circleProgressLayer: CircleProgressLayer {
        return layer as! CircleProgressLayer
    }

    /// Override and set `CircleProgressLayer` as `layerClass`
    override public class var layerClass: AnyClass {
        return CircleProgressLayer.self
    }
    
    // MARK: - Init
    
    public convenience init() {
        self.init(frame: .zero)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    /// Setup the `UIView`
    private func setup() {
        backgroundColor = .white
        
        clipsToBounds = false
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 0.75
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 3
        layer.shadowPath = shadowPath
        
        layer.setNeedsDisplay()
    }
    
    // MARK: - Animation
    
    /// Animate `progress`
    public func animateProgress(to value: CGFloat, duration: TimeInterval) {
        CATransaction.begin()
        
        let keyPath = #keyPath(CircleProgressLayer.progress)
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.duration = duration
        animation.fromValue = progress
        animation.toValue = value
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.isRemovedOnCompletion = true // false seems to continue to call draw(in)!
        animation.fillMode = .both
        
        CATransaction.setCompletionBlock{ [weak self] in
            self?.circleProgressLayer.progress = value
        }

        circleProgressLayer.add(animation, forKey: keyPath)
        CATransaction.commit()
    }
    
    // MARK: - UIView lifecycle
      
    var layerCornerRadius: CGFloat {
        return min(bounds.size.width, bounds.size.height) * 0.5
    }
    
    var shadowPath: CGPath {
        return UIBezierPath(roundedRect: bounds, cornerRadius: layerCornerRadius).cgPath
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = layerCornerRadius
        layer.shadowPath = shadowPath
    }
}
