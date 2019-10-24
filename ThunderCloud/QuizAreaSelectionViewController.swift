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
    
    open var circleColor: UIColor? = .white
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageView: ImageView!
    
    override open func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = ThemeManager.shared.theme.backgroundColor
        
        guard let question = question else {
            return
        }
        
        let imageAnalyser = ImageColorAnalyzer(image: question.selectionImage.image)
        imageAnalyser.analyze()
        circleColor = imageAnalyser.detailColor ?? .black
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let question = question else {
            return
        }
        
        if UIAccessibility.isVoiceOverRunning {
            UIAccessibility.post(notification: .announcement, argument: "This question cannot be completed with VoiceOver enabled, please navigate to the next question".localised(with: "_VOICEOVER_AREA_QUIZ_QUESTION_MESSAGE"))
            question.answerCorrectly()
        }
        
        imageView.accessibilityLabel = question.selectionImage.accessibilityLabel
        imageView.accessibilityTraits = [.allowsDirectInteraction]
        imageView.image = question.selectionImage.image
        let imageAspect = question.selectionImage.image.size.height / question.selectionImage.image.size.width
        heightConstraint.constant = imageAspect * imageView.frame.width
    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        
        let location = sender.location(ofTouch: 0, in: imageView)
        let relativeLocation = CGPoint(x: location.x / imageView.bounds.width, y: location.y / imageView.bounds.height)
        question?.answer = relativeLocation
        
        if let circle = circleLayer {
            circle.removeFromSuperlayer()
        }
        
        //Circle radius (Fixed for now)
        let radius: CGFloat = UI_USER_INTERFACE_IDIOM() == .pad ? 40 : 26
        
        //Generate a cricle
        circleLayer = CAShapeLayer()
        circleLayer?.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: radius*2, height: radius*2), cornerRadius: radius).cgPath
        
        //Move to centre of tapped area (Consider the circle radius on the touched point)
        circleLayer?.position = CGPoint(x: location.x - radius, y: location.y - radius)
        
        circleLayer?.fillColor = UIColor.clear.cgColor
        circleLayer?.strokeColor =  circleColor?.cgColor
        circleLayer?.lineWidth = 3;
        
        //Add circle
        sender.view?.layer.addSublayer(circleLayer!)
        
        // Configure animation
        let drawAnimation = CABasicAnimation(keyPath: "strokeEnd")
        drawAnimation.duration = 0.5
        drawAnimation.repeatCount = 1.0
        drawAnimation.isRemovedOnCompletion = false
        drawAnimation.fromValue = 0.0
        drawAnimation.toValue = 1.0
        drawAnimation.delegate = self
        drawAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        
        circleLayer?.add(drawAnimation, forKey: "drawCircleAnimation")
        
        guard let question = question else { return }
        delegate?.quizQuestionViewController(self, didChangeAnswerFor: question)
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
