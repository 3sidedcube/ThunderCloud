//
//  TextSelectionQuestion.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 05/09/2017.
//  Copyright © 2017 3sidedcube. All rights reserved.
//

import Foundation

/// The user is presented with a choice from textual options
class TextSelectionQuestion: QuizQuestion {
	
	let options: [String]
	
	let limit: Int
	
	let correctAnswer: [Int]
	
	var answer: [Int] = [] {
		didSet {
			postNotification(notification: .answerChanged, object: self)
		}
	}
	
	override init?(dictionary: [AnyHashable : Any]) {
		
		guard let optionDictionaries = dictionary["options"] as? [[AnyHashable : Any]] else { return nil }
		let options = optionDictionaries.flatMap { (optionDictionary) -> String? in
			return StormLanguageController.shared.string(for: optionDictionary)
		}
		if options.count == 0 {
			return nil
		}
		self.options = options
		
		if let limit = dictionary["limit"] as? Int {
			self.limit = limit
		} else {
			limit = 0
		}
		
		guard let answer = dictionary["answer"] as? [Int] else { return nil }
		correctAnswer = answer
		
		super.init(dictionary: dictionary)
	}
	
	override var isCorrect: Bool {
		get {
			return correctAnswer.sorted(by: {$0>$1}) == answer.sorted(by: {$0>$1})
		}
		set {}
	}
	
	override var answered: Bool {
		get {
			return limit > 0 ? (answer.count == limit) : (answer.count > 0)
		}
		set {}
	}
	
	override func reset() {
		answer = []
	}
	
	override func answerCorrectly() {
		answer = correctAnswer
	}
	
	override func answerRandomly() {
		while answer.count < limit {
			let answerOption = Int(arc4random_uniform(UInt32(options.count)))
			if !answer.contains(answerOption) {
				answer.append(answerOption)
			}
		}
	}
}
