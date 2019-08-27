//
//  QuizSliderViewController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 10/08/2017.
//  Copyright © 2017 3sidedcube. All rights reserved.
//

import UIKit
import ThunderTable

class QuizSliderViewController: UIViewController, QuizQuestionViewController {
    
    var delegate: QuizQuestionViewControllerDelegate?
    
    @IBOutlet weak var imageView: ImageView!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var question: ImageSliderQuestion?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = ThemeManager.shared.theme.backgroundColor
        
        guard let question = question else {
            return
        }
        
        if let image = question.sliderImage {
            
            imageView.accessibilityLabel = question.image?.accessibilityLabel
            imageView.image = image.image
            let imageAspect = image.image.size.height / image.image.size.width
            heightConstraint.constant = imageAspect * imageView.frame.width
        } else {
            heightConstraint.constant = 0
        }
        
        slider.minimumValue = Float(question.minValue)
        slider.maximumValue = Float(question.maxValue)
        
        amountLabel.text = "\(Int(slider.value))"
        
        if let initalValue = question.initialValue {
            slider.value = Float(initalValue)
        }
        
        amountLabel.text = "\(Int(slider.value)) \(question.unit ?? "")"
        slider.isUserInteractionEnabled = true
    }
    
    @IBAction func handleSlider(_ sender: UISlider) {
        
        amountLabel.text = "\(Int(slider.value)) \(question?.unit ?? "")"
        question?.answer = Int(slider.value)
        guard let question = question else { return }
        delegate?.quizQuestionViewController(self, didChangeAnswerFor: question)
    }
}
