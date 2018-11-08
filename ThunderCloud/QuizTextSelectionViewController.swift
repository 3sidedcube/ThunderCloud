//
//  QuizTextSelectionQuestionViewController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 10/08/2017.
//  Copyright © 2017 3sidedcube. All rights reserved.
//

import UIKit
import ThunderTable

class QuizTextSelectionViewController: TableViewController {

	var question: TextSelectionQuestion?
	
	var screenName: String?
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		view.backgroundColor = ThemeManager.shared.theme.backgroundColor
		
		guard let question = question else { return }
		
		tableView.allowsMultipleSelection = question.limit > 1
		tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 44+32, right: 0)
		
		let rows = question.options.enumerated().map { (index, option) -> Row in
			
			let selectionRow = SingleSelectionRow(title: option, id: option)
			
			// Value change handler for row
			selectionRow.valueChangeHandler = { (value, sender) -> Void in
				
				guard let boolValue = value as? Bool else { return }
				
				if let screenName = self.screenName {
					NotificationCenter.default.sendStatEventNotification(category: screenName, action: boolValue ? "Select Answer" : "Deselect Answer", label: "\(index)", value: nil, object: nil)
				}
				
				if boolValue {
					
					// If we've selected more answers than limit allows
					if question.limit > 1 && question.answer.count > question.limit - 1, let firstAnswer = question.answer.first {
						
						// Deselect the last selected (No need to remove it from the question object as deselect handler will do this for us)
						let removeIndexPath = IndexPath(row: firstAnswer, section: 0)
						self.tableView.deselectRow(at: removeIndexPath, animated: false)
						self.tableView(self.tableView, didDeselectRowAt: removeIndexPath)
					}
					
					// As long as it's not already selected
					if !question.answer.contains(index) {
						question.answer.append(index)
					}
					
				} else {
					
					if let removeIndex = question.answer.index(of: index) {
						question.answer.remove(at: removeIndex)
					}
				}
			}
			return selectionRow
		}
		
		data = [rows]
	}
}
