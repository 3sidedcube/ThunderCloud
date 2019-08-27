//
//  QuizBadgeScrollerViewCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 30/06/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation
import ThunderTable

/// A simple struct containing a badge and it's respective quiz
public struct QuizBadge {
    
    /// The badge this quizBadge is for
    public let badge: Badge
    
    /// The quiz (when applicable) this badge is for
    public let quiz: Quiz?
}

extension QuizBadge: CollectionCellDisplayable {
    
    public var itemTitle: String? {
        return badge.title ?? quiz?.title
    }
    
    public var itemImage: UIImage? {
        return badge.icon?.image
    }
    
    public var itemImageAccessibilityLabel: String? {
        return badge.icon?.accessibilityLabel
    }
    
    public var enabled: Bool {
        return BadgeController.shared.hasEarntBadge(with: badge.id)
    }
}

/// `QuizBadgeScrollerViewCell` is a `TableViewCell` with a `UICollectionView` inside of it.
/// It is used to display all of the badges in a single cell.
open class QuizBadgeCollectionCell: CollectionCell {
    
    /// This is called when a badge is clicked.
    ///
    /// It gets the relevant quiz for the badge and pushes a `TSCQuizPage` on to the screen.
    /// If a badge has been completed, it pushes the quizzes completion page
    ///
    /// - Parameter atIndexPath: The IndexPath of the selected collection view cell
    open func handleSelectedQuiz(atIndexPath: IndexPath) {
        
        guard let badgeQuizzes = items as? [QuizBadge] else { return }
        let badgeQuiz = badgeQuizzes[atIndexPath.row]
        guard let badgeId = badgeQuiz.badge.id else { return }
        let badge = badgeQuiz.badge
        let quiz = badgeQuiz.quiz
        
        if BadgeController.shared.hasEarntBadge(with: badgeId) {
            
            let defaultShareBadgeMessage = "Test Completed".localised(with: "_TEST_COMPLETED_SHARE")
            var items: [Any] = []
            
            if let badgeIcon = badge.icon {
                items.append(badgeIcon)
            }
            
            items.append(badge.shareMessage ?? defaultShareBadgeMessage)
            
            let shareViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
            
            if let keyWindow = UIApplication.shared.keyWindow {
                
                let cell = collectionView.cellForItem(at: atIndexPath)
                
                shareViewController.popoverPresentationController?.sourceView = cell ?? keyWindow
                shareViewController.popoverPresentationController?.sourceRect = cell != nil ? cell!.bounds : CGRect(x: keyWindow.frame.width/2, y: keyWindow.frame.maxY - 20, width: 32, height: 32)
                shareViewController.popoverPresentationController?.permittedArrowDirections = [.any]
            }
            
            shareViewController.completionWithItemsHandler = { (activityType, completed, returnedItems, activityError) in
                NotificationCenter.default.sendAnalyticsHook(.badgeShare(badge, (from: "BadgeScroller", destination: activityType, shared: completed)))
            }
            
            parentViewController?.present(shareViewController, animated: false, completion: nil)
            
        } else {
            
            guard let _quiz = quiz else { return }
            
            _quiz.restart()
            guard let quizQuestionViewController = _quiz.questionViewController() else { return }
            
            NotificationCenter.default.sendAnalyticsHook(.testStart(_quiz))
            
            if UI_USER_INTERFACE_IDIOM() == .pad {
                
                let quizNavigationController = UINavigationController(rootViewController: quizQuestionViewController)
                quizNavigationController.modalPresentationStyle = .formSheet
                let visibleViewController = UIApplication.shared.keyWindow?.visibleViewController
                
                if let visibleNavigation = visibleViewController?.navigationController, visibleViewController?.presentingViewController != nil {
                    
                    visibleNavigation.show(viewController: quizQuestionViewController, animated: true)
                    
                } else if let splitViewController = UIApplication.shared.keyWindow?.rootViewController as? SplitViewController {
                    
                    splitViewController.setRightViewController(quizQuestionViewController, from: self.parentViewController?.navigationController)
                    
                } else {
                    
                    parentViewController?.navigationController?.present(quizNavigationController, animated: true, completion: nil)
                }
                
            } else {
                
                quizQuestionViewController.hidesBottomBarWhenPushed = true
                parentViewController?.navigationController?.pushViewController(quizQuestionViewController, animated: true)
            }
        }
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: QUIZ_COMPLETED_NOTIFICATION, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: BADGES_CLEARED_NOTIFICATION, object: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: QUIZ_COMPLETED_NOTIFICATION, object: nil)
        NotificationCenter.default.removeObserver(self, name:  BADGES_CLEARED_NOTIFICATION, object: nil)
    }
}

//MARK: Collection view layout delegate
extension QuizBadgeCollectionCell {

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleSelectedQuiz(atIndexPath: indexPath)
    }
}
