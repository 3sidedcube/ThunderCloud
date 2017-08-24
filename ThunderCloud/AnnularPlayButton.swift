//
//  AnnularPlayButton.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 14/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// An animated play button that appears over video objects
open class AnnularPlayButton: UIView {

	/// The light image that animated around the outside of the play circle
	let lightView: UIImageView = UIImageView(image: UIImage(named: "TSCAnnularPlayButton", in: Bundle(for: AnnularPlayButton.self), compatibleWith: nil))
	
	/// The path that the animating image will take
	var pathLayer: CAShapeLayer = {
		
		let shapeLayer = CAShapeLayer()
		shapeLayer.strokeColor = UIColor.white.cgColor
		shapeLayer.fillColor = nil
		shapeLayer.lineWidth = 5.0
		shapeLayer.lineJoin = kCALineJoinRound
		
		return shapeLayer
	}()
	
	/// The background of the play button
	let backgroundView: UIView = UIView()
	
	/// The play image of the play button
	let playView: UIImageView = UIImageView(image: UIImage(named: "TSCAnnularPlayButton-play", in: Bundle(for: AnnularPlayButton.self), compatibleWith: nil))
	
	/// Whether or not the play button has finished it's animation
	var isFinished: Bool = true
	
	var samplePath: UIBezierPath {
		
		let center = CGPoint(x: bounds.width/2, y: bounds.height/2)
		let radius = (bounds.width - 1) / 2
		let startAngle = (-CGFloat.pi) / 2
		let endAngle = (2 * CGFloat.pi) + startAngle
		
		let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle:endAngle, clockwise: true)
		circlePath.lineCapStyle = .round
		
		return circlePath
	}
	
	/// Begins the animation that circles the play button
	///
	/// - Parameter delay: The number of seconds to wait before animating
	public func startAnimation(with delay: TimeInterval? = nil) {
		if let delay = delay {
			perform(#selector(_startAnimation), with: nil, afterDelay: delay)
		} else {
			_startAnimation()
		}
	}
	
	@objc private func _startAnimation() {
		
		if !isFinished {
			return
		}
		
		pathLayer.path = samplePath.cgPath
		if pathLayer.superlayer == nil {
			layer.addSublayer(pathLayer)
		}
		
		let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
		pathAnimation.duration = 1.2
		pathAnimation.fromValue = 0.0
		pathAnimation.toValue = 1.0
		pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
		
		let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
		rotationAnimation.toValue = -CGFloat.pi * 2
		rotationAnimation.duration = 1.2
		rotationAnimation.isCumulative = true
		rotationAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
		
		let alphaAnimation = CAKeyframeAnimation(keyPath: "opacity")
		alphaAnimation.values = [0.0, 1.0, 1.0, 1.0, 1.0, 0.0]
		alphaAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
		alphaAnimation.delegate = self
		
		pathLayer.add(pathAnimation, forKey: "strokeEnd")
		lightView.layer.add(rotationAnimation, forKey: "rotationAnimation")
		lightView.layer.add(alphaAnimation, forKey: "alphaAnimation")
	}
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		setupViews()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setupViews()
	}
	
	open override func awakeFromNib() {
		super.awakeFromNib()
		setupViews()
	}
	
	private func setupViews() {
		
		lightView.alpha = 0.0
		addSubview(lightView)
		
		backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
		backgroundView.layer.cornerRadius = 35
		backgroundView.alpha = 0.0
		addSubview(backgroundView)
		
		playView.tintColor = .white
		playView.alpha = 0.0
		addSubview(playView)
	}
	
	open override func layoutSubviews() {
		super.layoutSubviews()
		lightView.frame = CGRect(x: -10, y: -10, width: 90, height: 90)
		playView.frame = CGRect(x: 19, y: 15, width: 40, height: 40)
	}
}

extension AnnularPlayButton: CAAnimationDelegate {
	
	public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		
		UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: { 
			self.backgroundView.alpha = 1.0
			self.playView.alpha = 1.0
		}) { (finished) in
			self.isFinished = true
		}
	}
}
