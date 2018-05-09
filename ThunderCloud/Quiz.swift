//
//  QuizPageViewController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 10/08/2017.
//  Copyright © 2017 3sidedcube. All rights reserved.
//

import UIKit

public typealias Quiz = QuizPage

/// A representation of an entire storm quiz
open class QuizPage: StormObjectProtocol {
	
	/// The identifier of the badge that this quiz represents
	public var badgeId: String?
	
	/// The questions that need to be answered in the quiz
	public let questions: [QuizQuestion]?
	
	/// The current question position in the quiz
	public var currentIndex: Int = 0
	
	/// Unique identifier of the quiz
	public let id: String?
	
	/// Title of the quiz
	public let title: String?
	
	/// Message to be shown if answered quiz incorrectly
	public let loseMessage: String?
	
	/// Message to be shown if answered quiz correctly
	public let winMessage: String?
	
	/// Message to be shared when share quiz results
	public let shareMessage: String?
	
	/// Related links if answered quiz incorrectly
	public let loseRelatedLinks: [StormLink]?
	
	/// Related links if answered quiz correctly
	public let winRelatedLinks: [StormLink]?
	
	required public init(dictionary: [AnyHashable : Any]) {
		
		if let children = dictionary["children"] as? [[AnyHashable : Any]] {
			
			questions = children.enumerated().compactMap({ (index, quizDictionary) -> QuizQuestion? in
				
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
		} else {
			title = nil
		}
		
		if let winObject = dictionary["winMessage"] as? [AnyHashable : Any] {
			winMessage = StormLanguageController.shared.string(for: winObject)
		} else {
			winMessage = nil
		}
		
		if let loseObject = dictionary["loseMessage"] as? [AnyHashable : Any] {
			loseMessage = StormLanguageController.shared.string(for: loseObject)
		} else {
			loseMessage = nil
		}
		
		if let shareObject = dictionary["shareMessage"] as? [AnyHashable : Any] {
			shareMessage = StormLanguageController.shared.string(for: shareObject)
		} else {
			shareMessage = nil
		}
		
		loseRelatedLinks = (dictionary["loseRelatedLinks"] as? [[AnyHashable : Any]])?.compactMap({
			StormLink(dictionary: $0)
		})
		
		winRelatedLinks = (dictionary["winRelatedLinks"] as? [[AnyHashable : Any]])?.compactMap({
			StormLink(dictionary: $0)
		})
		
		if let intId = dictionary["badgeId"] as? Int {
			badgeId = "\(intId)"
		} else if let stringId = dictionary["badgeId"] as? String {
			badgeId = stringId
		}
		
		//answerRandomly()
	}
	
	/// Restarts the quiz by removing all answers and setting currentIndex to 0
	public func restart() {
		questions?.forEach({ (question) in
			question.reset()
		})
		currentIndex = 0
	}
	
	/// Whether the quiz was answered entirely and correctly
	public var answeredCorrectly: Bool {
		guard let questions = questions else { return true }
		return questions.filter({$0.isCorrect}).count == questions.count
	}
	
	/// Creates a new view controller for displaying a question
	///
	/// This is provided as a function in order to allow easier overriding of Quiz when custom UI is needed.
	///
	/// - Important: Note, this view controller should be responsible for laying out the current question by accessing it from the `Quiz` object,
	/// as opposed to having the question set on it.
	///
	/// - Returns: A view controller to display a quiz question
	open func questionViewController() -> UIViewController? {
		
		let bundle = Bundle(for: Quiz.self)
		guard let quizQuestionContainerViewController = UIStoryboard(name: "Quiz", bundle: bundle).instantiateInitialViewController() as? QuizQuestionContainerViewController else { return nil }
		quizQuestionContainerViewController.quiz = self
		return quizQuestionContainerViewController
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
