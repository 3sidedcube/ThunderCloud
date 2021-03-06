//
//  CircleView.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 05/12/2019.
//  Copyright © 2019 BenShutt. All rights reserved.
//

import UIKit
import ThunderBasics

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
    
    /// Round the corners of this view to make a circle
    private var roundCorners = true {
        didSet {
            updateCornerRadius()
        }
    }
    
    /// Apply shadow configuration based on `shadowComponents` property
    public var hasShadow = true {
        didSet {
            updateShadow()
        }
    }
    
    /// The shadow components to be applied if `hasShadow` = true
    var shadowComponents: ShadowComponents? = .init(
        radius: 3,
        opacity: 0.75,
        color: .lightGray,
        offset: .zero
    ) {
        didSet {
            updateShadow()
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
        
        updateCornerRadius()
        updateShadow()
        
        layer.setNeedsDisplay()
    }
    
    // MARK: - UI
    
    var layerCornerRadius: CGFloat {
        return roundCorners ? min(bounds.size.width, bounds.size.height) * 0.5 : 0
    }
    
    var shadowPath: CGPath? {
        guard hasShadow else {
            return nil
        }
        return UIBezierPath(roundedRect: bounds, cornerRadius: layerCornerRadius).cgPath
    }
    
    private func updateCornerRadius() {
        layer.cornerRadius = roundCorners ? layerCornerRadius : 0
    }
    
    private func updateShadow() {
        shadow = hasShadow ? shadowComponents : nil
        layer.shadowPath = shadowPath
    }
    
    // MARK: - Animation
    
    /// Animate `progress`
    ///
    /// - Parameters:
    ///   - value: Value to set `progress` to at the "end" of the animation
    ///   - duration: How long to animate for
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
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = layerCornerRadius
        layer.shadowPath = shadowPath
    }
}
