//
//  QuizPageViewController.swift
//  GNAH
//
//  Created by Simon Mitchell on 10/08/2017.
//  Copyright © 2017 3sidedcube. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

public class Quiz: StormObjectProtocol {
	
	let questions: [QuizQuestion]?
	
	var currentIndex: Int = 0
	
	let id: String?
	
	let title: String?
	
	required public init(dictionary: [AnyHashable : Any]) {
		
		if let children = dictionary["children"] as? [[AnyHashable : Any]] {
			
			questions = children.enumerated().flatMap({ (index, quizDictionary) -> QuizQuestion? in
				
				guard let quizClass = quizDictionary["class"] as? String else { return nil }
				switch quizClass {
				case "ImageSliderSelectionQuestion", "SliderSelectionQuestion":
					return ImageSliderQuestion(dictionary: quizDictionary)
				case "ImageSelectionQuestion":
					return ImageSelectionQuestion(dictionary: quizDictionary)
				case "TextSelectionQuestion":
					return TextSelectionQuestion(dictionary: quizDictionary)
				case "AreaSelectionQuestion", "AreaQuizItem":
					return AreaSelectionQuestion(dictionary: quizDictionary)
				default:
					return nil
				}
			})
			
			questions?.enumerated().forEach({ (index, question) in
				question.questionNumber = index + 1
			})
			
		} else {
			questions = nil
		}
		
		if let idString = dictionary["id"] as? String {
			id = idString
		} else if let idInt = dictionary["id"] as? Int {
			id = "\(idInt)"
		} else {
			id = nil
		}
		
		if let titleObject = dictionary["title"] as? [AnyHashable : Any] {
			title = StormLanguageController.shared.string(for: titleObject)
		}
		//answerRandomly()
	}
	
	convenience init?(cacheURL: URL) {
		
		guard let pageURL = ContentController.shared.url(forCacheURL: cacheURL) else { return nil }
		guard let pageData = try? Data(contentsOf: pageURL) else { return nil }
		guard let pageObject = try? JSONSerialization.jsonObject(with: pageData, options: []) else { return nil }
		guard let pageDictionary = pageObject as? [AnyHashable : Any] else { return nil }
		
		self.init(dictionary: pageDictionary)
	}
	
	func restart() {
		questions?.forEach({ (question) in
			question.reset()
		})
		currentIndex = 0
	}
	
	var answeredCorrectly: Bool {
		guard let questions = questions else { return true }
		return questions.filter({$0.isCorrect}).count == questions.count
	}
	
	/// This is a private function, but can be called internally to mock question answers
	private func answerCorrectly() {
		
		questions?.forEach({ (question) in
			question.answerCorrectly()
		})
	}
	
	/// This is a private function, but can be called internally to mock question answers
	private func answerRandomly() {
		
		questions?.forEach({ (question) in
			question.answerRandomly()
		})
	}
}
