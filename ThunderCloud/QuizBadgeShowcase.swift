//
//  QuizBadgeShowcase.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// A table row which shows a collection of badges related to the quizzes available in the application
///
/// Incomplete quizzes (or the badge attached to them) are shown slightly transparent.
///
/// Once a badge has been earnt clicking on it will open a share sheet for the user to share the badge
open class QuizBadgeShowcase: ListItem {
    
    /// The array of badges to be displayed in the row
    open lazy var badges: [Badge] = { [unowned self] in
    
        return quizzes.compactMap({
            return $0.badge
        })
    }()
    
    private lazy var quizzes: [Quiz] = { [unowned self] in
        
        guard let quizURLs = quizURLs else { return [] }
        
        return quizURLs.compactMap({ quizURL in
            guard let pageURL = URL(string: quizURL) else { return nil }
            return StormGenerator.quiz(for: pageURL)
        })
    }()
    
    private var completedQuizObserver: NSObjectProtocol?
    
    private var quizURLs: [String]?
    
    deinit {
        if let completedQuizObserver = completedQuizObserver {
            NotificationCenter.default.removeObserver(completedQuizObserver)
        }
    }
    
    public required init(dictionary: [AnyHashable : Any]) {
        
        super.init(dictionary: dictionary)
        
        quizURLs = dictionary["quizzes"] as? [String]
        
        completedQuizObserver = NotificationCenter.default.addObserver(forName: QUIZ_COMPLETED_NOTIFICATION, object: nil, queue: .main, using: { [weak self] (notification) in
            guard let self = self else {
                return
            }
            
            self.parentViewController?.tableView?.reloadData()
            
            // Check to see if we have earned all the quiz badges
            let badges = self.quizzes
                .compactMap({ $0.badge })
                .filter({ $0.expirableAchievement != nil })
            
            if self.quizzes.count == badges.count {
                self.allQuizzsComplete()
            }
        })
    }
    
    override open var cellClass: UITableViewCell.Type? {
        
        if let cellClass = StormObjectFactory.shared.class(for: NSStringFromClass(QuizBadgeCollectionCell.self)) as? UITableViewCell.Type {
            return cellClass
        } else {
            return QuizBadgeCollectionCell.self
        }
    }
    
    var cellItems: [CollectionCellDisplayable]? {
        return badges.map({ (badge) -> QuizBadge in
            return QuizBadge(badge: badge, quiz: quizzes.first(where: { $0.badgeId == badge.id }))
        })
    }
    
    override open func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        
        super.configure(cell: cell, at: indexPath, in: tableViewController)
        
        guard let scrollerCell = cell as? CollectionCell else { return }
        
        scrollerCell.items = cellItems
        scrollerCell.clipsToBounds = false
        scrollerCell.contentView.clipsToBounds = false
        scrollerCell.collectionView.clipsToBounds = false
    }
    
    override open var accessoryType: UITableViewCell.AccessoryType? {
        get {
            return UITableViewCell.AccessoryType.none
        }
        set {}
    }
    
    override open var selectionStyle: UITableViewCell.SelectionStyle? {
        get {
            return UITableViewCell.SelectionStyle.none
        }
        set {}
    }
    
    override open var useNibSuperclass: Bool {
        return false
    }
    
    open override var displaySeparators: Bool {
        get {
            return false
        }
        set { }
    }
    
    override open var estimatedHeight: CGFloat? {
        return 192
    }
    
    override open func height(constrainedTo size: CGSize, in tableView: UITableView) -> CGFloat? {
        let itemSizes = cellItems?.compactMap({ CollectionItemViewCell.size(for: $0) }).sorted { (size1, size2) -> Bool in
            size1.height > size2.height
        }
        guard let maxSize = itemSizes?.first else { return estimatedHeight }
        return maxSize.height
    }
    
    // MARK: - Quiz
    
    /// Called when all the quiz badges are achieved
    private func allQuizzsComplete() {
        guard let quizCompletion = try? QuizCompletionManager.quizCompletion() else {
            return
        }
        
        let viewController = AllQuizzesCompleteViewController(quizCompletion: quizCompletion)
        parentViewController?.present(viewController, animated: true)
    }
}
