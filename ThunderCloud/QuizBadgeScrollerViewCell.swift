//
//  QuizBadgeScrollerViewCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 30/06/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation

/// `QuizBadgeScrollerViewCell` is a `TableViewCell` with a `UICollectionView` inside of it.
/// It is used to display all of the badges in a single cell.
open class QuizBadgeScrollerViewCell: CollectionCell {
    
    /// An array of `Badge`s to be displayed in the collection view
    open var badges: [Badge]? {
        didSet {
            reload()
        }
    }
    
    /// An array of `TSCQuizPage`s which are pushed onto screen when a badge is selected
    open var quizzes: [Quiz]?
    
    /// This is called when a badge is clicked.
    ///
    /// It gets the relevant quiz for the badge and pushes a `TSCQuizPage` on to the screen.
    /// If a badge has been completed, it pushes the quizzes completion page
    ///
    /// - Parameter atIndexPath: The IndexPath of the selected collection view cell
    open func handleSelectedQuiz(atIndexPath: IndexPath) {
        
        guard let badges = badges else { return }
        let badge = badges[atIndexPath.row]
        guard let badgeId = badge.id else { return }
        
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
            
            guard let quiz = quizzes?.first(where: { (quizPage) -> Bool in
                
                guard let id = quizPage.badge?.id, let testId = badge.id else { return false }
                return id == testId
            }) else {
                return
            }
            
            quiz.restart()
            guard let quizQuestionViewController = quiz.questionViewController() else { return }
            
            NotificationCenter.default.sendAnalyticsHook(.testStart(quiz))
            
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
        
        collectionView.register(UINib(nibName: "BadgeScrollerItemViewCell", bundle: Bundle(for: BadgeScrollerItemViewCell.self)), forCellWithReuseIdentifier: "Cell")
        
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
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
    }
}

//MARK: Collection view layout delegate
extension QuizBadgeScrollerViewCell {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let badges = badges else {
            return CGSize.zero
        }
        
        let badge = badges[indexPath.item]
        return BadgeScrollerItemViewCell.sizeFor(badge: badge)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleSelectedQuiz(atIndexPath: indexPath)
    }
}

//MARK: Collection view datasource
extension QuizBadgeScrollerViewCell {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.badges?.count ?? 0
    }
    
    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        guard let badge = badges?[indexPath.item], let badgeCell = cell as? BadgeScrollerItemViewCell else {
            return cell
        }
        
        badgeCell.badgeImageView.accessibilityLabel = badge.iconAccessibilityLabel
        badgeCell.badgeImageView.image = badge.icon
        
        if let title = badgeCell.titleLabel.text, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            badgeCell.titleContainerView.isHidden = false
        } else {
            badgeCell.titleContainerView.isHidden = true
        }
        badgeCell.titleLabel.text = badge.title
        
        let hasEarnt = badge.id != nil ? BadgeController.shared.hasEarntBadge(with: badge.id!) : false
        badgeCell.badgeImageView.alpha = hasEarnt ? 1.0 : 0.44
        
        badgeCell.layoutSubviews()
        
        return badgeCell
    }
}
