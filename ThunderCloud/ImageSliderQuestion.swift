//
//  ImageSliderQuestion.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 05/09/2017.
//  Copyright © 2017 3sidedcube. All rights reserved.
//

import UIKit

/// The user is presented with an image and a slider to choose a value
public class ImageSliderQuestion: QuizQuestion {
	
	public let correctAnswer: Int
	
	/// (Cannot be called `image` due to Row conformance)
	public let sliderImage: UIImage?
	
	public let initialValue: Int?
	
	public let minValue: Int
	
	public let maxValue: Int
	
	public let unit: String?
	
	public var answer: Int? {
		didSet {
			postNotification(notification: .answerChanged, object: self)
		}
	}
	
	override init?(dictionary: [AnyHashable : Any]) {
		
		if let imageObject = dictionary["image"], let image = StormGenerator.image(fromJSON: imageObject) {
			sliderImage = image
		} else {
			sliderImage = nil
		}
		
		guard let answer = dictionary["answer"] as? Int else { return nil }
		correctAnswer = answer
		
		guard let range = dictionary["range"] as? [AnyHashable : Any] else { return nil }
		guard let min = range["start"] as? Int, let length = range["length"] as? Int else { return nil }
		minValue = min
		maxValue = min + length
		
		initialValue = dictionary["initialPosition"] as? Int
		
		if let unitDictionary = dictionary["unit"] as? [AnyHashable : Any] {
			unit = StormLanguageController.shared.string(for: unitDictionary)
		} else {
			unit = nil
		}
		
		super.init(dictionary: dictionary)
	}
	
    override public var isCorrect: Bool {
		get {
			return correctAnswer == answer
		}
		set {}
	}
	
    override public var answered: Bool {
		get {
			return answer != nil
		}
		set {}
	}
	
    override public func reset() {
		answer = nil
	}
	
	override func answerCorrectly() {
		answer = correctAnswer
	}
	
	override func answerRandomly() {
		answer = Int(arc4random_uniform(UInt32(maxValue - minValue))) + minValue
	}
}
