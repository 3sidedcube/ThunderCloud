//
//  QuizQuestions.swift
//  GNAH
//
//  Created by Simon Mitchell on 05/09/2017.
//  Copyright © 2017 3sidedcube. All rights reserved.
//

import Foundation
import ThunderBasics

public class QuizQuestion {
	
	//MARK: -
	//MARK: Shared Properties
	//MARK: -
	
	let question: String?
	
	let hint: String?
	
	let completionText: String?
	
	let failureText: String?
	
	let winText: String?
	
	var isCorrect: Bool = false
	
	var answered: Bool = false
	
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
	
	func reset() {
		
	}
	
	func answerCorrectly() {
		
	}
	
	func answerRandomly() {
		
	}
}

extension QuizQuestion: Notifier {
	
	public enum Notification: String {
		case answerChanged
	}
}
