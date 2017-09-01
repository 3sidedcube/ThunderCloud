//
//  CollectionListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// Defines what the `CollectionListItem` is displaying
public enum CollectionListItemType {
	
	/// Collection view is displaying quiz badges
	case quiz
	/// Collection view is displaying apps
	case app
	/// Collection view is displaying links
	case link
	/// Collection view is displaying generic badges
	case badge
	/// An unknown list of items
	case unknown
}

/// A storm item representing a collection of items displayed in a horizontal UICollectionView
open class CollectionListItem: ListItem {

	/// Defines what the collection list item is displaying
	public var type: CollectionListItemType = .unknown
	
	/// The array of badges to display in the collection
	public var badges: [Badge]?
	
	/// The array of apps to display in the collection
	public var apps: [TSCAppCollectionItem]?
	
	/// The array of links to display in the collection
	public var links: [TSCLinkCollectionItem]?
	
	/// The array of quizzes to display in the collection
	public var quizzes: [TSCQuizPage]?
	
	private var quizCompletetionObserver: NSObjectProtocol?
	
	deinit {
		if let quizCompletionObserver = quizCompletetionObserver {
			NotificationCenter.default.removeObserver(quizCompletionObserver)
		}
	}
	
	public required init(dictionary: [AnyHashable : Any]) {
		
		super.init(dictionary: dictionary)
		
		guard let collectionCells = dictionary["cells"] as? [[AnyHashable : Any]], let cellClass = collectionCells.first?["class"] as? String else { return }
		
		switch cellClass {
			case "QuizCollectionItem", "QuizCollectionCell":
				type = .quiz
				setupQuizzes(with: collectionCells)
			break
			case "AppCollectionItem", "AppCollectionCell":
				type = .app
				apps = collectionCells.map({ (collectionCell) -> TSCAppCollectionItem in
					return TSCAppCollectionItem(dictionary: collectionCell)
				})
			break
			case "LinkCollectionItem", "LinkCollectionCell":
				type = .link
				links = collectionCells.map({ (collectionCell) -> TSCLinkCollectionItem in
					return TSCLinkCollectionItem(dictionary: collectionCell)
				})
			break
			case "BadgeCollectionCell", "BadgeCollectionItem":
				type = .badge
				setupBadges(with: collectionCells)
			default:
				print("[STORM] Unknown cell type set on CollectionListItem")
		}
	}
	
	private func setupQuizzes(with items: [[AnyHashable : Any]]) {
		
		var _badges: [Badge] = []
		var _quizzes: [TSCQuizPage] = []
		
		items.forEach { (quizCell) in
			
			// Make sure qe have a ["quiz"]["destination"] and a badge for the quiz
			guard let quizDestination = (quizCell["quiz"] as? [AnyHashable : Any])?["destination"] as? String, let badgeId = quizCell["badgeId"], let badge = BadgeController.shared.badge(for: "\(badgeId)") else {
				return
			}
			
			//TODO: Move this logic into a new init method on TSCQuizPage
			// Load the TSCQuizPage object
			guard let quizURL = ContentController.shared.url(forCacheURL: URL(string: quizDestination)) else {
				return
			}
			guard let quizData = try? Data(contentsOf: quizURL), let quizObject = try? JSONSerialization.jsonObject(with: quizData, options: []), let quizDictionary = quizObject as? [AnyHashable : Any] else {
				return
			}
			
			guard let quiz = StormObjectFactory.shared.stormObject(with: quizDictionary) as? TSCQuizPage else {
				return
			}
			
			quiz.badgeId = badge.id
			_badges.append(badge)
			_quizzes.append(quiz)
		}
		
		badges = _badges
		quizzes = _quizzes
		
		quizCompletetionObserver = NotificationCenter.default.addObserver(forName: QUIZ_COMPLETED_NOTIFICATION, object: nil, queue: .main) { [weak self] (notification) -> Void in
			self?.handleQuizCompletion()
		}
	}
	
	private func setupBadges(with items: [[AnyHashable : Any]]) {
		
		badges = items.flatMap({ (badgeCell) -> Badge? in
			
			var badgeId: String? = badgeCell["badgeId"] as? String
			if let badgeNumberId = badgeCell["badgeId"] as? Int {
				badgeId = "\(badgeNumberId)"
			}
			
			guard let _badgeId = badgeId else { return nil }
			return BadgeController.shared.badge(for: _badgeId)
		})
	}
	
	private func handleQuizCompletion() {
		if let tableViewController = parentNavigationController?.visibleViewController as? TableViewController {
			tableViewController.tableView.reloadData()
		}
	}
	
	//MARK: -
	//MARK: Row protocol
	//MARK: -
	
	override open func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		
		super.configure(cell: cell, at: indexPath, in: tableViewController)
		
		switch type {
		case .quiz:
			guard let quizBadgeScrollerCell = cell as? QuizBadgeScrollerViewCell else { return }
			quizBadgeScrollerCell.quizzes = quizzes
			quizBadgeScrollerCell.badges = badges
			parentNavigationController = quizBadgeScrollerCell.parentNavigationController
		break
		case .app:
			guard let appCollectionCell = cell as? AppCollectionCell else { return }
			appCollectionCell.apps = apps
			parentNavigationController = appCollectionCell.parentNavigationController
		break
		case .link:
			guard let linkCollectionCell = cell as? LinkCollectionCell else { return }
			linkCollectionCell.links = links
			parentNavigationController = linkCollectionCell.parentNavigationController
		break
		case .badge:
			guard let badgeScrollerCell = cell as? BadgeScrollerViewCell else { return }
			badgeScrollerCell.badges = badges
			parentNavigationController = badgeScrollerCell.parentNavigationController
		default: break
		}
	}
	
	override public func height(constrainedTo size: CGSize, in tableView: UITableView) -> CGFloat? {
		return estimatedHeight
	}
	
	override public var estimatedHeight: CGFloat? {
		switch type {
		case .quiz:
			return 180
		case .app:
			return 130
		case .link:
			return 120
		case .badge:
			return 192
		default:
			return 160
		}
	}
	
	override public var cellClass: AnyClass? {
		
		switch type {
		case .quiz:
			return StormObjectFactory.shared.class(for: NSStringFromClass(QuizBadgeScrollerViewCell.self)) as? UITableViewCell.Type ?? QuizBadgeScrollerViewCell.self
		case .app:
			return StormObjectFactory.shared.class(for: NSStringFromClass(AppCollectionCell.self)) as? UITableViewCell.Type ?? AppCollectionCell.self
		case .link:
			return StormObjectFactory.shared.class(for: NSStringFromClass(LinkCollectionCell.self)) as? UITableViewCell.Type ?? LinkCollectionCell.self
		case .badge:
			return StormObjectFactory.shared.class(for: NSStringFromClass(BadgeScrollerViewCell.self)) as? UITableViewCell.Type ?? BadgeScrollerViewCell.self
		default:
			return nil
		}
	}
	
	public var selectionStyle: UITableViewCellSelectionStyle? {
		get {
			return UITableViewCellSelectionStyle.none
		}
		set {}
	}
	
	public var accessoryType: UITableViewCellAccessoryType? {
		get {
			return UITableViewCellAccessoryType.none
		}
		set {}
	}
	
	override public var useNibSuperclass: Bool {
		return false
	}
}
