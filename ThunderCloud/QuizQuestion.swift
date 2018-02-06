//
//  QuizQuestions.swift
//  GNAH
//
//  Created by Simon Mitchell on 05/09/2017.
//  Copyright © 2017 3sidedcube. All rights reserved.
//

import Foundation
import ThunderBasics

/// A class that represents a base question for a quiz, should be subclassed to implement
/// a specific question type
public class QuizQuestion {
	
	//MARK: -
	//MARK: Shared Properties
	//MARK: -
	
	/// The question itself, e.g. What is the square root of pi
	let question: String?
	
	/// A hint or instruction for answering the question
	let hint: String?
	
	/// Text to be displayed when the question has been answered
	let completionText: String?
	
	/// Text to be displayed if the question is answered incorrectly
	let failureText: String?
	
	/// Text to be displayed if the question is answered correctly
	let winText: String?
	
	/// Whether the question was answered correctly
	var isCorrect: Bool = false
	
	/// Whether the question has been answered
	var answered: Bool = false
	
	/// The question's position in the quiz
	var questionNumber: Int?
	
	init?(dictionary: [AnyHashable : Any]) {
		
		if let titleDictionary = dictionary["title"] as? [AnyHashable : Any] {
			question = StormLanguageController.shared.string(for: titleDictionary)
		} else {
			question = nil
		}
		
		if let hintDictionary = dictionary["hint"] as? [AnyHashable : Any] {
			hint = StormLanguageController.shared.string(for: hintDictionary)
		} else {
			hint = nil
		}
		
		if let completionDictionary = dictionary["completion"] as? [AnyHashable : Any] {
			completionText = StormLanguageController.shared.string(for: completionDictionary)
		} else {
			completionText = nil
		}
		
		if let failureDictionary = dictionary["failure"] as? [AnyHashable : Any] {
			failureText = StormLanguageController.shared.string(for: failureDictionary)
		} else {
			failureText = nil
		}
		
		if let winDictionary = dictionary["win"] as? [AnyHashable : Any] {
			winText = StormLanguageController.shared.string(for: winDictionary)
		} else {
			winText = nil
		}
	}
	
	/// Resets the answer to the question
	///
	/// This should be overidden in subclasses
	func reset() {
		
	}
	
	/// Answers the question correctly
	///
	/// This should be overidden in subclasses
	internal func answerCorrectly() {
		
	}
	
	/// Answers the question randomly
	///
	/// This should be overidden in subclasses
	internal func answerRandomly() {
		
	}
}

extension QuizQuestion: Notifier {
	
	public enum Notification: String {
		case answerChanged
	}
}
