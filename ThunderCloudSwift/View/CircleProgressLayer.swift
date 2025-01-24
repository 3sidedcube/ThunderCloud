//
//  CircleProgressLayer.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 05/12/2019.
//  Copyright © 2019 BenShutt. All rights reserved.
//

import UIKit

/// Layer to draw a circular progress path.
/// 2 paths:
/// - background path which covers a whole circle
/// - progress path on top of the backgroundPath only drawn as far as the progress
open class CircleProgressLayer: CALayer {
    
    // MARK: - Properties
    
    /// A real number in the range [0, 1].
    /// Determines what percentage of `progressPath` is taken up by the `backgroundPath`.
    @objc public var progress: CGFloat = 0 { didSet{ setNeedsDisplay() } }
    
    /// The angle which the `progressPath` starts at.
    ///
    /// - Note:
    /// The angle 0 represents the straight line right from the circle center when
    /// looking from above. The angles then increases to 2π in the clockwise direction.
    public var startAngle: CGFloat = 3 * CGFloat.pi / 2 { didSet{ setNeedsDisplay() } }
    
    /// Does the progress increase in the clockwise direction
    public var clockwise = true { didSet{ setNeedsDisplay() } }
    
    /// The percentage which determines the radius of the central hole relative to `R`
    @objc public var radiusScale: CGFloat = 0.9 { didSet{ setNeedsDisplay() } }
    
    /// The stroke colour of the `progressPath`
    public var pathColor = UIColor.red { didSet{ setNeedsDisplay() } }
    
    /// The stroke colour of the `backgroundPath`
    public var backgroundPathColor = UIColor.red.withAlphaComponent(0.4) { didSet{ setNeedsDisplay() } }
    
    // MARK: - Init
    
    /// Default init
    public override init() {
        super.init()
    }
    
    /// Init with `layer`
    public override init(layer: Any) {
        super.init(layer: layer)
        guard let cv = layer as? CircleProgressLayer else {
            return
        }
        
        progress = cv.progress
        startAngle = cv.startAngle
        clockwise = cv.clockwise
        radiusScale = cv.radiusScale
        pathColor = cv.pathColor
        backgroundPathColor = cv.backgroundPathColor
    }
    
    /// Init with `coder`
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Computed Properties
    
    /// Distance of path upper bound from the center.
    private var R: CGFloat {
        return min(bounds.size.width, bounds.size.height) * 0.5
    }
    
    /// Distance of path lower bound from the center.
    /// Scale `R` by `radiusScale`
    private var r: CGFloat {
        return R * radiusScale
    }
    
    /// Difference between upper and lower bound radius
    private var strokeWidth: CGFloat {
        return R - r
    }
    
    /// Halfway between lower and upper bound radii (stroke from the middle)
    private var strokeRadius: CGFloat {
        return r + strokeWidth * 0.5
    }
    
    // MARK: - Draw

    /// Instruct to Core Animation that a change in one of these properties should automatically
    /// trigger a redraw of the layer.
    private static let keyPaths = [
        #keyPath(progress),
        #keyPath(radiusScale)
    ]
    
    /// Check if `key` can be found in `displayKeyPaths`. If so, trigger a re-draw
    override open class func needsDisplay(forKey key: String) -> Bool {
        if keyPaths.contains(key) {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
    
    /// Execute draw functionality
    override open func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        UIGraphicsPushContext(ctx)
        
        // Stroke background path
        strokePath(scale: 1, color: backgroundPathColor)
        
        // Stroke path
        strokePath(scale: progress, color: pathColor)
        
        UIGraphicsPopContext()
    }
    
    // MARK: - Path
    
    /// Draw a circle about the bounds center, configure the path according to custom properties
    private func strokePath(scale: CGFloat, color: UIColor) {
        let center = CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)
        
        let path =  UIBezierPath(
            arcCenter: center,
            radius: strokeRadius,
            startAngle: startAngle,
            endAngle: startAngle + CGFloat.pi * 2 * (clockwise ? scale : -scale),
            clockwise: clockwise)
        
        path.lineWidth = strokeWidth
        color.setStroke()
        path.stroke()
    }
    
}
