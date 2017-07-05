//
//  QuizProgressListItemView.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 05/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// A table row which displays a user's progress through a set of quizzes and upon selection enters the next incomplete quiz in the set
class QuizProgressListItemView: ListItem {

	/// An array of quizzes available to the user
	var availableQuizzes: [TSCQuizPage]?
	
	/// The url reference to the next incomplete quiz for the user
	var nextQuizURL: URL?
	
	required init(dictionary: [AnyHashable : Any], parentObject: StormObjectProtocol?) {
		
		super.init(dictionary: dictionary, parentObject: parentObject)
		
		if let quizURLs = dictionary["quizzes"] as? [String] {
			
			availableQuizzes = quizURLs.flatMap({ (quizURL) -> TSCQuizPage? in
				//TODO: Finish Him!
				return nil
			})
		}
	}
}
