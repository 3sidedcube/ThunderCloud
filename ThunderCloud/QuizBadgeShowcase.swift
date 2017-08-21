//
//  QuizBadgeShowcase.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// A table row which shows a collection of badges related to the quizzes available in the application
///
/// Incomplete quizzes (or the badge attached to them) are shown slightly transparent.
///
/// Once a badge has been earnt clicking on it will open a share sheet for the user to share the badge
open class QuizBadgeShowcase: ListItem {

	/// The array of badges to be displayed in the row
	open var badges: [Badge] = []
	
	private var quizzes: [TSCQuizPage] = []
	
	private var completedQuizObserver: NSObjectProtocol?
	
	deinit {
		if let _completedQuizObserver = completedQuizObserver {
			NotificationCenter.default.removeObserver(_completedQuizObserver)
		}
	}
	
	public required init(dictionary: [AnyHashable : Any]) {
		
		super.init(dictionary: dictionary)
		
		guard let quizzesArray = dictionary["quizzes"] as? [String] else { return }
		
		quizzesArray.forEach { (quizURL) in
			
			guard let pageURL = ContentController.shared.url(forCacheURL: URL(string: quizURL)) else { return }
			guard let pageData = try? Data(contentsOf: pageURL) else { return }
			guard let pageObject = try? JSONSerialization.jsonObject(with: pageData, options: []) else { return }
			guard let pageDictionary = pageObject as? [AnyHashable : Any] else { return }
			guard let quizPage = StormObjectFactory.shared.stormObject(with: pageDictionary) as? TSCQuizPage else { return }
			
			if let badge = quizPage.badge {
				badges.append(badge)
			}
			
			quizzes.append(quizPage)
		}
		
		completedQuizObserver = NotificationCenter.default.addObserver(forName: QUIZ_COMPLETED_NOTIFICATION, object: nil, queue: .main, using: { [weak self] (notification) in
			
			if let tableViewController = self?.parentNavigationController?.visibleViewController as? UITableViewController {
				tableViewController.tableView.reloadData()
			}
		})
	}
	
	override public var cellClass: AnyClass? {
		
		if let cellClass = StormObjectFactory.shared.class(for: NSStringFromClass(QuizBadgeScrollerViewCell.self)) as? UITableViewCell.Type {
			return cellClass
		} else {
			return QuizBadgeScrollerViewCell.self
		}
	}
	
	public override func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		
		super.configure(cell: cell, at: indexPath, in: tableViewController)
		
		guard let scrollerCell = cell as? QuizBadgeScrollerViewCell else { return }
		
		scrollerCell.badges = badges
		scrollerCell.quizzes = quizzes
	}
	
	public var accessoryType: UITableViewCellAccessoryType? {
		get {
			return UITableViewCellAccessoryType.none
		}
		set {}
	}
	
	public var selectionStyle: UITableViewCellSelectionStyle? {
		get {
			return UITableViewCellSelectionStyle.none
		}
		set {}
	}
	
	public override var useNibSuperclass: Bool {
		return false
	}
	
	public override var estimatedHeight: CGFloat? {
		return 160
	}
	
	public override func height(constrainedTo size: CGSize, in tableView: UITableView) -> CGFloat? {
		return 160
	}
}
