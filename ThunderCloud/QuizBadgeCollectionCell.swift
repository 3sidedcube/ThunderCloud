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

extension Quiz {
    
    /// `Badge` of `Quiz`
    public var badge: Badge? {
        guard let badgeId = badgeId else {
            return nil
        }
        return BadgeController.shared.badge(for: badgeId)
    }
}

extension Badge {
    
    /// If the `Badge` has a `validFor` field, then it degrades over time.
    /// Lookup in db when the `Badge` was earned to get its `ExpirableAchievement`
    public var expirableAchievement: ExpirableAchievement? {
        return BadgeDB.shared.expirableAchievement(for: self)
    }
}

extension QuizBadge: CollectionCellDisplayable {
       
    public var itemTitle: String? {
        return badge.title ?? quiz?.title
    }
    
    public var itemImage: StormImage? {
        return badge.icon
    }
    
    public var enabled: Bool {
        return BadgeController.shared.hasEarntBadge(with: badge.id)
    }
    
    public var expirableAchievement: ExpirableAchievement? {
        return badge.expirableAchievement
    }
    
    public var accessibilityLabel: String? {
        let params = [
            "BADGE_NAME": itemTitle ?? "Unknown".localised(with: "_QUIZ_BADGE_UNKNOWN")
        ]
        return enabled ?
            "{BADGE_NAME}. Passed.".localised(with: "_QUIZ_BADGE_PASSED", paramDictionary: params) :
            "{BADGE_NAME}. Not passed.".localised(with: "_QUIZ_BADGE_NOT_PASSED", paramDictionary: params)
    }
    
    public var accessibilityHint: String? {
        guard let badgeId = badge.id else { return nil }
        if BadgeController.shared.hasEarntBadge(with: badgeId) {
            return "Double tap to share".localised(with: "_QUIZ_BADGE_PASSED_ACCESSIBILITYHINT")
        } else if quiz != nil {
            return "Double tap to take quiz".localised(with: "_QUIZ_BADGE_NOT_PASSED_ACCESSIBILITYHINT")
        }
        return nil
    }
    
    public var accessibilityTraits: UIAccessibilityTraits {
        return [.button]
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
        let quizBadge = badgeQuizzes[atIndexPath.row]
        guard let badgeId = quizBadge.badge.id else { return }
        
        if BadgeController.shared.hasEarntBadge(with: badgeId) {
            share(quizBadge: quizBadge, indexPath: atIndexPath)
        } else {
            retake(quizBadge: quizBadge)
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
    
    // MARK: - Actions
    
    /// Share the `badge` of a `QuizBadge`
    private func share(quizBadge: QuizBadge, indexPath: IndexPath) {
        let badge = quizBadge.badge

        let viewController = UIApplication.visibleViewController
        viewController?.presentShare(
            quizBadge.badge,
            defaultShareMessage: "Test Completed".localised(with: "_TEST_COMPLETED_SHARE"),
            sourceView: .view(self)
        ) { activityType, completed, _, _ in
            NotificationCenter.default.sendAnalyticsHook(
                .badgeShare(badge, (
                    from: "BadgeScroller",
                    destination: activityType,
                    shared: completed
                ))
            )
        }
    }
    
    /// Retake the `quiz` of a `QuizBadge`
    private func retake(quizBadge: QuizBadge) {
        guard let _quiz = quizBadge.quiz else { return }
        
        _quiz.restart()
        guard let quizQuestionViewController = _quiz.questionViewController() else { return }
        
        NotificationCenter.default.sendAnalyticsHook(.testStart(_quiz))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            let quizNavigationController = UINavigationController(rootViewController: quizQuestionViewController)
            quizNavigationController.modalPresentationStyle = .formSheet
            let visibleViewController = UIApplication.shared.appKeyWindow?.visibleViewController
            
            if let visibleNavigation = visibleViewController?.navigationController, visibleViewController?.presentingViewController != nil {
                
                visibleNavigation.show(viewController: quizQuestionViewController, animated: true)
                
            } else if let splitViewController = UIApplication.shared.appKeyWindow?.rootViewController as? SplitViewController {
                
                splitViewController.setRightViewController(quizQuestionViewController, from: self.parentViewController?.navigationController)
                
            } else {
                
                parentViewController?.navigationController?.present(quizNavigationController, animated: true, completion: nil)
            }
            
        } else {
            
            let navigationController = parentViewController?.navigationController
            quizQuestionViewController.hidesBottomBarWhenPushed =
                navigationController?.shouldHideBottomBarWhenPushed() ?? false
            navigationController?.pushViewController(quizQuestionViewController, animated: true)
        }
    }
}

//MARK: Collection view layout delegate
extension QuizBadgeCollectionCell {

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleSelectedQuiz(atIndexPath: indexPath)
    }
}
