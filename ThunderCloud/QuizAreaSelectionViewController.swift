//
//  QuizAreaSelectionViewController.swift
//  GNAH
//
//  Created by Simon Mitchell on 10/08/2017.
//  Copyright © 2017 3sidedcube. All rights reserved.
//

import UIKit
import ThunderTable
import ThunderBasics

open class QuizAreaSelectionViewController: UIViewController, QuizQuestionViewController {
    
    var delegate: QuizQuestionViewControllerDelegate?
    
    open var question: AreaSelectionQuestion?
    
    fileprivate var circleLayer: CAShapeLayer?
    
    fileprivate var circleShadowLayer: CAShapeLayer?
    
    fileprivate var circleInnerLayer: CAShapeLayer?
    
    public static var CircleInnerColor: UIColor = ThemeManager.shared.theme.mainColor
    
    public static var CircleOuterColor: UIColor = .white
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageView: ImageView!
    
    override open func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = ThemeManager.shared.theme.backgroundColor
        
        guard let question = question else {
            return
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let question = question else {
            return
        }
        
        imageView.accessibilityLabel = question.selectionImage.accessibilityLabel
        imageView.isAccessibilityElement = question.selectionImage.accessibilityLabel != nil
        imageView.accessibilityTraits = [.allowsDirectInteraction]
        imageView.image = question.selectionImage.image
        let imageAspect = question.selectionImage.image.size.height / question.selectionImage.image.size.width
        heightConstraint.constant = imageAspect * imageView.frame.width
        
        guard UIAccessibility.isVoiceOverRunning else { return }
        
        imageView.image = nil
        imageView.isHidden = true
        
        question.answerCorrectly()
        delegate?.quizQuestionViewController(self, didChangeAnswerFor: question)
    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        
        let location = sender.location(ofTouch: 0, in: imageView)
        let relativeLocation = CGPoint(x: location.x / imageView.bounds.width, y: location.y / imageView.bounds.height)
        question?.answer = relativeLocation
        
        [circleLayer, circleInnerLayer, circleShadowLayer].forEach({ $0?.removeFromSuperlayer() })
        
        //Circle radius (Fixed for now)
        let radius: CGFloat = UI_USER_INTERFACE_IDIOM() == .pad ? 40 : 26
        
        //Generate a cricle
        circleLayer = circleLayer(radius: radius, fillColor: .clear, strokeColor: QuizAreaSelectionViewController.CircleOuterColor, lineWidth: 6)
        circleInnerLayer = circleLayer(radius: radius, fillColor: .clear, strokeColor: QuizAreaSelectionViewController.CircleInnerColor, lineWidth: 2)
        circleShadowLayer = circleLayer(radius: radius, fillColor: .clear, strokeColor: UIColor(white: 0.0, alpha: 0.1), lineWidth: 8)
        
        //Move to centre of tapped area (Consider the circle radius on the touched point)
        circleLayer?.position = CGPoint(x: location.x - radius, y: location.y - radius)
        circleInnerLayer?.position = circleLayer!.position
        circleShadowLayer?.position = circleLayer!.position
        
        //Add circle
        sender.view?.layer.addSublayer(circleShadowLayer!)
        sender.view?.layer.addSublayer(circleLayer!)
        sender.view?.layer.addSublayer(circleInnerLayer!)
        
        // Configure animation
        let drawAnimation = CABasicAnimation(keyPath: "strokeEnd")
        drawAnimation.duration = 0.5
        drawAnimation.repeatCount = 1.0
        drawAnimation.isRemovedOnCompletion = false
        drawAnimation.fromValue = 0.0
        drawAnimation.toValue = 1.0
        drawAnimation.delegate = self
        drawAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        
        circleShadowLayer?.add(drawAnimation, forKey: "drawCircleAnimation")
        circleInnerLayer?.add(drawAnimation, forKey: "drawCircleAnimation")
        circleLayer?.add(drawAnimation, forKey: "drawCircleAnimation")
        
        guard let question = question else { return }
        delegate?.quizQuestionViewController(self, didChangeAnswerFor: question)
    }
    
    fileprivate func circleLayer(radius: CGFloat, fillColor: UIColor, strokeColor: UIColor, lineWidth: CGFloat) -> CAShapeLayer {
        
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: radius*2, height: radius*2), cornerRadius: radius).cgPath
        layer.fillColor = fillColor.cgColor
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = lineWidth
    }
}

extension QuizAreaSelectionViewController: CAAnimationDelegate {
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        guard let basicAnimation = anim as? CABasicAnimation, flag else { return }
        guard basicAnimation.keyPath == "strokeEnd" else { return }
        
        circleLayer?.fillColor = UIColor.white.withAlphaComponent(0.30).cgColor
        
        let fillAnimation = CABasicAnimation(keyPath: "fillColor")
        fillAnimation.duration = 0.5
        fillAnimation.repeatCount = 1.0
        fillAnimation.isRemovedOnCompletion = false
        fillAnimation.fromValue = UIColor.clear.cgColor
        fillAnimation.toValue = UIColor.white.withAlphaComponent(0.30).cgColor
        
        circleLayer?.add(fillAnimation, forKey: "fillCircleAnimation")
    }
}
