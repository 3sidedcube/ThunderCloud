//
//  QuizTextSelectionQuestionViewController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 10/08/2017.
//  Copyright © 2017 3sidedcube. All rights reserved.
//

import UIKit
import ThunderTable

open class QuizTextSelectionViewController: TableViewController, QuizQuestionViewController {
    
    var delegate: QuizQuestionViewControllerDelegate?
    
    var question: TextSelectionQuestion?
    
    var quiz: Quiz?
    
    var screenName: String?
    
    open override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = ThemeManager.shared.theme.backgroundColor
        
        guard let question = question else { return }
        
        tableView.allowsMultipleSelection = question.limit > 1
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 44+32, right: 0)
        clearsSelectionOnViewWillAppear = false
        
        let rows = question.options.enumerated().map { (index, option) -> Row in
            
            let selectionRow = SingleSelectionRow(title: option, id: option)
            
            // Value change handler for row
            selectionRow.valueChangeHandler = { (value, sender) -> Void in
                
                guard let boolValue = value as? Bool else { return }
                
                NotificationCenter.default.sendAnalyticsHook(boolValue ? .testSelectTextAnswer(self.quiz, question, index) : .testDeselectTextAnswer(self.quiz, question, index))
                
                if boolValue {
                    
                    // If we've selected more answers than limit allows
                    if question.answer.count > question.limit - 1, let lastAnswer = question.answer.last {
                        
                        // Deselect the last selected (No need to remove it from the question object as deselect handler will do this for us)
                        let removeIndexPath = IndexPath(row: lastAnswer, section: 0)
                        self.tableView.deselectRow(at: removeIndexPath, animated: false)
                        self.tableView(self.tableView, didDeselectRowAt: removeIndexPath)
                        
                        // If the row selected wasn't the same as the answer beforehand (Clicking the same item to deselect)
                        // then add it to the question's answers
                        if lastAnswer != index {
                            question.answer.append(index)
                        }

                        // As long as it's not already selected

                    } else if !question.answer.contains(index) {
                        question.answer.append(index)
                    }
                    
                } else {
                    
                    if let removeIndex = question.answer.firstIndex(of: index) {
                        question.answer.remove(at: removeIndex)
                    }
                }
                
                self.delegate?.quizQuestionViewController(self, didChangeAnswerFor: question)
            }
            return selectionRow
        }
        
        data = [rows]
    }
}
