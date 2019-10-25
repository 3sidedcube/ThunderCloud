//
//  QuizSliderViewController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 10/08/2017.
//  Copyright © 2017 3sidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// A protocol which must be impelemented by users of `SliderAccessibilityElement` which allows the provision of:
///  accessibility values, the values allowed by the slider and performs accessibility scrolling
protocol SliderAccessibilityElementDataSource {
    
    /// This is used by a `CarouselAcccessibilityElement` to fetch the `accessibilityValue` for the element at a given index
    /// - Parameter element: The accessibility element which is asking for an `accessibilityValue`
    /// - Parameter index: The index of the value to return
    func sliderAccessibilityElement(_ element: SliderAccessibilityElement, accessibilityValueFor sliderValue: Float) -> String?
    
    /// This is used by a `SliderAccessibilityElement` to fetch the max value of the slider to make sure we don't move it to far
    /// - Parameter element: The accessibility element requesting the maximum value
    func maximumValue(for element: SliderAccessibilityElement) -> Float
    
    /// This is used by a `SliderAccessibilityElement` to fetch the min value of the slider to make sure we don't move it to far
    /// - Parameter element: The accessibility element requesting the minimum value
    func minimumValue(for element: SliderAccessibilityElement) -> Float
    
    /// This is used by a `SliderAccessibilityElement` to request a movement in a given direction
    /// - Parameter element: The accessibility element that requested the scroll
    /// - Parameter index: The index the accessibility element wants to scroll to
    func sliderAccessibilityElement(_ element: SliderAccessibilityElement, changeValueIn direction: SliderAccessibilityElement.SlideDirection)
}

/// A subclass of `UIAccessibilityElement` which simplifies all the logic that is needed to implement a slider-like accessibility control.
/// Return an instance of this class from your container element's `accessibilityElements` to implement slider control in Voice Over.
public class SliderAccessibilityElement: UIAccessibilityElement {
    
    enum SlideDirection {
        case increase
        case decrease
    }
    
    /// The source for the data which this accessibility element needs to function
    var dataSource: SliderAccessibilityElementDataSource?
    
    /// Creates a new slider accessibility element for the given container and dataSource
    /// - Parameter container: The container element for the accessibility element
    /// - Parameter dataSource: The data source used to perform accessibility functions
    init(accessibilityContainer container: Any, dataSource: SliderAccessibilityElementDataSource) {
        super.init(accessibilityContainer: container)
        self.dataSource = dataSource
    }
    
    /// The current value which is selected in the slider
    var currentValue: Float = 0
    
    override public var accessibilityTraits: UIAccessibilityTraits {
        get {
            return [.adjustable]
        }
        set {
            super.accessibilityTraits = newValue
        }
    }
    
    override public var accessibilityValue: String? {
        get {
            return dataSource?.sliderAccessibilityElement(self, accessibilityValueFor: currentValue)
        }
        set {
            super.accessibilityValue = newValue
        }
    }
    
    // MARK: Accessibility

    override public func accessibilityIncrement() {
        // Initialize the container view which will house the collection view.
        guard let dataSource = dataSource else { return }
        let maxValue = dataSource.maximumValue(for: self)
        guard currentValue < maxValue else { return }
        dataSource.sliderAccessibilityElement(self, changeValueIn: .increase)
    }
    
    override public func accessibilityDecrement() {
        guard let dataSource = dataSource else { return }
        let minValue = dataSource.minimumValue(for: self)
        guard currentValue > minValue else { return }
        dataSource.sliderAccessibilityElement(self, changeValueIn: .decrease)
    }
}

class QuizSliderViewController: UIViewController, QuizQuestionViewController {
    
    var delegate: QuizQuestionViewControllerDelegate?
    
    @IBOutlet weak var imageView: ImageView!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sliderContainerView: UIView!
    
    var question: ImageSliderQuestion?
    
    private var sliderAccessibilityElement: SliderAccessibilityElement?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = ThemeManager.shared.theme.backgroundColor
        
        guard let question = question else {
            return
        }
        
        if let image = question.sliderImage {
            
            imageView.accessibilityLabel = question.image?.accessibilityLabel
            imageView.isAccessibilityElement = question.image?.accessibilityLabel != nil
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
        
        sliderContainerView.isAccessibilityElement = false
        sliderContainerView.accessibilityLabel = "Answer Slider".localised(with: "_QUIZ_VOICEOVER_SLIDER")
        
        guard let sliderContainerView = sliderContainerView else { return }
        
        sliderAccessibilityElement =             SliderAccessibilityElement(accessibilityContainer: sliderContainerView, dataSource: self)
        sliderContainerView.accessibilityElements = [
            sliderAccessibilityElement!
        ]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sliderAccessibilityElement?.accessibilityFrameInContainerSpace = sliderContainerView.bounds
    }
    
    @IBAction func handleSlider(_ sender: UISlider) {
        
        amountLabel.text = "\(Int(slider.value)) \(question?.unit ?? "")"
        question?.answer = Int(slider.value)
        sliderAccessibilityElement?.currentValue = slider.value
        guard let question = question else { return }
        delegate?.quizQuestionViewController(self, didChangeAnswerFor: question)
    }
}

extension QuizSliderViewController: SliderAccessibilityElementDataSource {
    
    func sliderAccessibilityElement(_ element: SliderAccessibilityElement, accessibilityValueFor sliderValue: Float) -> String? {
        return "\(Int(slider.value)) \(question?.unit ?? "")"
    }
    
    func sliderAccessibilityElement(_ element: SliderAccessibilityElement, changeValueIn direction: SliderAccessibilityElement.SlideDirection) {
        switch direction {
        case .increase:
            slider.setValue(slider.value + 1.0, animated: true)
        case .decrease:
            slider.setValue(slider.value - 1.0, animated: true)
        }
        slider.sendActions(for: .valueChanged)
    }
    
    func maximumValue(for element: SliderAccessibilityElement) -> Float {
        return slider.maximumValue
    }
    
    func minimumValue(for element: SliderAccessibilityElement) -> Float {
        return slider.minimumValue
    }
}
