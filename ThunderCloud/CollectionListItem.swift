//
//  CollectionListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

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
    public var apps: [AppCollectionItem]?
    
    /// The array of links to display in the collection
    public var links: [LinkCollectionItem]?
    
    /// The array of quizzes to display in the collection
    public var quizzes: [Quiz]?
    
    private var quizCompletetionObserver: NSObjectProtocol?
    
    deinit {
        if let quizCompletionObserver = quizCompletetionObserver {
            NotificationCenter.default.removeObserver(quizCompletionObserver)
        }
        quizCompletetionObserver = nil
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
            apps = collectionCells.map({ (collectionCell) -> AppCollectionItem in
                return AppCollectionItem(dictionary: collectionCell)
            })
            break
        case "LinkCollectionItem", "LinkCollectionCell":
            type = .link
            links = collectionCells.compactMap({ (collectionCell) -> LinkCollectionItem? in
                return LinkCollectionItem(dictionary: collectionCell)
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
        var _quizzes: [Quiz] = []
        
        items.forEach { (quizCell) in
            
            // Make sure qe have a ["quiz"]["destination"] and a badge for the quiz
            guard let quizDestination = (quizCell["quiz"] as? [AnyHashable : Any])?["destination"] as? String, let badgeId = quizCell["badgeId"], let badge = BadgeController.shared.badge(for: "\(badgeId)") else {
                return
            }
            
            // Load the Quiz object
            guard let quizURL = URL(string: quizDestination) else {
                return
            }
            guard let quiz = StormGenerator.quiz(for: quizURL) else {
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
        
        badges = items.compactMap({ (badgeCell) -> Badge? in
            
            var badgeId: String? = badgeCell["badgeId"] as? String
            if let badgeNumberId = badgeCell["badgeId"] as? Int {
                badgeId = "\(badgeNumberId)"
            }
            
            guard let _badgeId = badgeId else { return nil }
            return BadgeController.shared.badge(for: _badgeId)
        })
    }
    
    private func handleQuizCompletion() {
        parentViewController?.tableView?.reloadData()
    }
    
    //MARK: -
    //MARK: Row protocol
    //MARK: -
    
    var cellItems: [CollectionCellDisplayable]? {
        switch type {
        case .quiz:
            return badges?.map({ (badge) -> QuizBadge in
                let quiz = quizzes?.first(where: { $0.badgeId == badge.id })
                return QuizBadge(badge: badge, quiz: quiz)
            })
        case .app:
            return apps
        case .link:
            return links
        case .badge:
            return badges
        case .unknown:
            return nil
        }
    }
    
    override open func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        
        super.configure(cell: cell, at: indexPath, in: tableViewController)
        
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        cell.contentView.clipsToBounds = false
        cell.clipsToBounds = false
        
        guard let collectionCell = cell as? CollectionCell else { return }
        
        collectionCell.collectionView.clipsToBounds = false
        collectionCell.items = cellItems
    }
    
    override open func height(constrainedTo size: CGSize, in tableView: UITableView) -> CGFloat? {
        
        guard let cellItems = cellItems else { return estimatedHeight }
    
        let itemSizes = cellItems.map({ CollectionItemViewCell.size(for: $0) }).sorted { (size1, size2) -> Bool in
            size1.height > size2.height
        }
        guard let firstItem = itemSizes.first else {
            return estimatedHeight
        }
        
        return firstItem.height + CollectionCell.Constants.sectionInsets.verticalSum
    }
    
    override open var estimatedHeight: CGFloat? {
        return 192
    }
    
    override open var cellClass: UITableViewCell.Type? {
        
        switch type {
        case .quiz:
            return StormObjectFactory.shared.class(for: NSStringFromClass(QuizBadgeCollectionCell.self)) as? UITableViewCell.Type ?? QuizBadgeCollectionCell.self
        case .app:
            return StormObjectFactory.shared.class(for: NSStringFromClass(AppCollectionCell.self)) as? UITableViewCell.Type ?? AppCollectionCell.self
        case .link:
            return StormObjectFactory.shared.class(for: NSStringFromClass(LinkCollectionCell.self)) as? UITableViewCell.Type ?? LinkCollectionCell.self
        case .badge:
            return StormObjectFactory.shared.class(for: NSStringFromClass(BadgeCollectionCell.self)) as? UITableViewCell.Type ?? BadgeCollectionCell.self
        default:
            return nil
        }
    }
    
    open override var displaySeparators: Bool {
        get {
            return false
        }
        set { }
    }
    
    override open var selectionStyle: UITableViewCell.SelectionStyle? {
        return UITableViewCell.SelectionStyle.none
    }
    
    override open var accessoryType: UITableViewCell.AccessoryType? {
        get {
            return UITableViewCell.AccessoryType.none
        }
        set {}
    }
    
    override open var useNibSuperclass: Bool {
        return false
    }
}
