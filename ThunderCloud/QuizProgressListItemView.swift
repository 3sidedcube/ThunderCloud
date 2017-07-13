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
	
	/// The link for this list item is calculated based on the next quiz
	override var link: TSCLink? {
		get {
			guard let nextQuizID = nextQuiz?.quizId else {
				return nil
			}
			guard let nextQuizLink = URL(string: "cache://pages/\(nextQuizID).json") else {
				return nil
			}
			return TSCLink(url: nextQuizLink)
		}
		set {
			super.link = newValue
		}
	}
	
	private var completedQuizzes: Int {
		
		guard let _quizzes = availableQuizzes else {
			return 0
		}
		
		return _quizzes.filter({ (quiz) -> Bool in
			guard let quizBadgeId = quiz.quizBadge.badgeId else {
				return false
			}
			return TSCBadgeController.shared().hasEarntBadge(withId: quizBadgeId)
		}).count
	}
	
	private var nextQuiz: TSCQuizPage? {
		return availableQuizzes?.first(where: { (quiz) -> Bool in
			
			guard let badgeId = quiz.quizBadge.badgeId else { return true }
			
			return !TSCBadgeController.shared().hasEarntBadge(withId: badgeId)
		})
	}
	
	private var nextQuizObserver: NSObjectProtocol?
	
	private var quizCompletedObserver: NSObjectProtocol?
	
	private var badgesClearedObserver: NSObjectProtocol?
	
	deinit {
		if let _nextQuizObserver = nextQuizObserver {
			NotificationCenter.default.removeObserver(_nextQuizObserver)
		}
		if let _quizCompletedObserver = quizCompletedObserver {
			NotificationCenter.default.removeObserver(_quizCompletedObserver)
		}
		if let _badgesClearedObserver = badgesClearedObserver {
			NotificationCenter.default.removeObserver(_badgesClearedObserver)
		}
	}
	
	required init(dictionary: [AnyHashable : Any]) {
		
		super.init(dictionary: dictionary)
		
		if let quizURLs = dictionary["quizzes"] as? [String] {
			
			availableQuizzes = quizURLs.flatMap({ (quizURL) -> TSCQuizPage? in
				
				guard let pagePath = ContentController.shared.url(forCacheURL: URL(string: quizURL)) else {
					return nil
				}
				guard let pageData =  try? Data(contentsOf: pagePath) else {
					return nil
				}
				guard let pageObject = try? JSONSerialization.jsonObject(with: pageData, options: []), let pageDict = pageObject as? [AnyHashable : Any] else {
					return nil
				}
				
				return StormObjectFactory.shared.stormObject(with: pageDict) as? TSCQuizPage
			})
			
			// This is obsolete for the moment as this notification isn't sent by anywhere
			nextQuizObserver = NotificationCenter.default.addObserver(forName: OPEN_NEXT_QUIZ_NOTIFICATION, object: nil, queue: .main, using: { [weak self] (notification) in
				self?.showNextQuiz(with: notification.object as? String)
			})
			
			quizCompletedObserver = NotificationCenter.default.addObserver(forName: QUIZ_COMPLETED_NOTIFICATION, object: nil, queue: .main, using: { [weak self] (notification) in
				self?.reloadData()
			})
			
			badgesClearedObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.init(rawValue: BADGES_CLEARED_NOTIFICATION), object: nil, queue: .main, using: { [weak self] (notification) in
				self?.reloadData()
			})
		}
	}
	
	private func reloadData() {
		
		if let tableVC = parentNavigationController?.visibleViewController as? TableViewController {
			tableVC.tableView.reloadData()
		}
	}
	
	//MARK: -
	//MARK: Helpers
	//MARK: -
	
	private func showNextQuiz(with quizId: String?) {
		
		guard let _quizId = quizId else { return }
		guard let nextQuiz = availableQuizzes?.first(where: { (quiz) -> Bool in
			guard let testQuizId = quiz.quizId else { return false }
			return testQuizId == _quizId
		}) else {
			return
		}
		guard let nextQuizID = nextQuiz.quizId else { return }
		guard let nextQuizURL = URL(string: "cache://pages/\(nextQuizID)") else { return }
		
		let link = TSCLink(url: nextQuizURL)
		parentNavigationController?.push(link)
	}
	
	//MARK: -
	//MARK: - Row Protocol
	//MARK: -
	
	override var cellClass: AnyClass? {
		return ProgressListItemCell.self
	}
	
	override func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		
		super.configure(cell: cell, at: indexPath, in: tableViewController)
		
		guard let progressCell = cell as? ProgressListItemCell else { return }
		let allQuizzesCompleted = availableQuizzes != nil && availableQuizzes!.count == completedQuizzes
		
		progressCell.cellTextLabel.isHidden = allQuizzesCompleted
		progressCell.cellTextLabel.text = "Next".localised(with: "_QUIZ_BUTTON_NEXT")
		progressCell.cellDetailLabel.text = allQuizzesCompleted ? "Completed".localised(with: "_TEST_COMPLETE") : nextQuiz?.quizTitle
		
		if let _availableQuizzes = availableQuizzes {
			if TSCStormLanguageController.shared().isRightToLeft() {
				progressCell.progressLabel.text = "\(_availableQuizzes.count) / \(completedQuizzes)"
			} else {
				progressCell.progressLabel.text = "\(completedQuizzes) / \(_availableQuizzes.count)"
			}
		} else {
			progressCell.progressLabel.text = "? / ?"
		}
		
		progressCell.selectionStyle = allQuizzesCompleted ? .none : .gray
	}
	
	var accessoryType: UITableViewCellAccessoryType? {
		guard let quizzes = availableQuizzes else { return .none }
		return completedQuizzes == quizzes.count ? .disclosureIndicator : .none
	}
}
