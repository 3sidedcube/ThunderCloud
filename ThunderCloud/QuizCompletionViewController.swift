//
//  QuizCompletionViewController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 03/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

public let QUIZ_COMPLETED_NOTIFICATION = NSNotification.Name.init("QUIZ_COMPLETED_NOTIFICATION")

/// A row to represent a quizzes related links!
class RelatedLinkRow: TableRow {
    
    let link: StormLink
    
    init(link: StormLink) {
        self.link = link
        super.init(title: link.title)
    }
    
    override func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        super.configure(cell: cell, at: indexPath, in: tableViewController)
        cell.accessibilityHint = link.accessibilityHint
        cell.accessibilityTraits = link.accessibilityTraits
    }
}

extension QuizQuestion: Row {
    
    public var title: String? {
        return isCorrect ? "Correct".localised(with: "_TEST_CORRECT") : question
    }
    
    public var subtitle: String? {
        return isCorrect ? winText : failureText
    }
    
    public var cellClass: UITableViewCell.Type? {
        return StormObjectFactory.shared.class(for: String(describing: NumberedViewCell.self)) as? NumberedViewCell.Type ?? NumberedViewCell.self
    }
    
    public func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        
        guard let numberCell = cell as? NumberedViewCell else { return }
        
        numberCell.embeddedLinksStackView.isHidden = true
        
        if let questionNumber = questionNumber {
            
            numberCell.numberLabel.text = "\(questionNumber)"
            numberCell.numberLabel.isHidden = false
            
        } else {
            
            numberCell.numberLabel.text = nil
            numberCell.numberLabel.isHidden = true
        }
        
        numberCell.cellTextLabel?.isHidden = title?.isEmpty ?? true
        numberCell.cellDetailLabel?.isHidden = subtitle?.isEmpty ?? true
        
        numberCell.cellTextLabel?.font = ThemeManager.shared.theme.cellTitleFont
        numberCell.cellDetailLabel?.font = ThemeManager.shared.theme.cellDetailFont
        
        numberCell.numberLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 28, textStyle: .title2, weight: .medium)
        
        // We have no links so make sure to get rid of the spacing on mainStackView
        numberCell.mainStackView?.spacing = 0
    }
    
    public var accessoryType: UITableViewCell.AccessoryType? {
        return UITableViewCell.AccessoryType.none
    }
    
    public var selectionStyle: UITableViewCell.SelectionStyle? {
        return UITableViewCell.SelectionStyle.none
    }
}

/// A view which will be shown to the user upon them answering all of the questions in a quiz
///
/// This view will calculate whether the user has answered the quiz correctly and display either hints on which questions a user answered incorrectly, or display a congratulatory view
///
/// This class will also send out `NotificationCenter` notifications to alert other views that the user has completed a quiz
open class QuizCompletionViewController: TableViewController {
    
    //MARK: -
    //MARK: Declarations
    //MARK: -
    
    private var hasPoppedIn = false
    
    /// An array of `UIBarButtonItem`s to be displayed to the user in the left of the navigation bar
    ///
    /// Defaults to a share button
    open var additionalLeftBarButtonItems: [UIBarButtonItem]? {
        return [
            UIBarButtonItem(
                title: "Share".localised(with: "_QUIZ_BUTTON_SHARE"),
                style: .plain,
                target: self,
                action: #selector(shareBadge(sender:))
            )
        ]
    }
    
    /// The button to be displayed to the user on the right of the navigation bar
    ///
    /// Defaults to a button to finish the quiz
    open var rightBarButtonItem: UIBarButtonItem? {
        get {
            
            // Don't show the right bar button on iPad unless we're being presented
            if UI_USER_INTERFACE_IDIOM() == .pad && self.presentingViewController == nil {
                return nil
            }
            
            return UIBarButtonItem(
                title: "Finish".localised(with: "_QUIZ_BUTTON_FINISH"),
                style: .plain,
                target: self,
                action: #selector(finishQuiz(sender:)))
        }
    }
    
    /// A handler to be called when a user selects to retry the quiz
    ///
    /// If provided this will override the default behaviour of `QuizCompletionViewController`
    public var retryHandler: SelectionHandler?
    
    /// The quiz the user has just come from
    public let quiz: Quiz
    
    private var winMessage: String?
    
    /// Returns a table row for a link related to the completed quiz
    ///
    /// This may, for example, contain a link to a token or sale if a user has correctly answered the quiz
    ///
    /// - Parameters:
    ///   - relatedLink: The link which the row should take the user to upon selection
    ///   - quizCorrect: Whether the user completed the quiz correctly
    /// - Returns: An object conforming to `Row` protocol
    open func row(for relatedLink: StormLink, quizCorrect: Bool) -> Row? {
        return RelatedLinkRow(link: relatedLink)
    }
    
    //MARK: -
    //MARK: View Controller Lifecycle
    //MARK: -
    
    /// Creates a new completion screen with the `Quiz` which the user has just completed
    ///
    /// - Parameters:
    ///   - quiz: The quiz the user has just come from / completed
    public required init(quiz: Quiz) {
        
        self.quiz = quiz
        
        super.init(style: .plain)
        
        winMessage = quiz.winMessage
        // If the user hasn't earned the badge associated with this quiz, then use the badge completion text
        if let badgeId = quiz.badgeId, !BadgeController.shared.hasEarntBadge(with: badgeId) {
            winMessage = quiz.badge?.completionText ?? winMessage
        }
        
        title = quiz.title
        navigationItem.setHidesBackButton(true, animated: true)
        
        
        if quiz.answeredCorrectly {
            
            navigationItem.leftBarButtonItems = additionalLeftBarButtonItems
            setupLeftNavigationBarButtons()
            
            NotificationCenter.default.sendAnalyticsHook(.testWin(quiz))
        } else {
            
            NotificationCenter.default.sendAnalyticsHook(.testLose(quiz))
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        quiz = Quiz(dictionary: [:])
        super.init(coder: aDecoder)
    }
    
    private var achievementDisplayView: UIView?
    
    override open func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = rightBarButtonItem
        tableView.backgroundColor = ThemeManager.shared.theme.backgroundColor
        
        if !quiz.answeredCorrectly {
            
            var sections: [Section] = []
            
            if let loseMessage = quiz.loseMessage {
                
                let failRow = StormTableRow(title: loseMessage)
                let failSection = TableSection(rows: [failRow])
                sections.append(failSection)
            }
            
            if let questions = quiz.questions {
                let questionSection = TableSection(rows: questions)
                sections.append(questionSection)
            }
            
            let tryAgainRow = StormTableRow(title: "Try again?".localised(with: "_QUIZ_BUTTON_AGAIN"), subtitle: nil, image: nil, selectionHandler: { (row, selected, indexPath, tableView) -> (Void) in
                
                if selected {
                    
                    if let retryHandler = self.retryHandler {
                        
                        retryHandler(row, selected, indexPath, tableView)
                        
                    } else {
                        
                        NotificationCenter.default.sendAnalyticsHook(.testReattempt(self.quiz))
                        
                        guard let quizId = self.quiz.id, let link = StormLink(pageId: quizId) else { return }
                        self.navigationController?.push(link: link)
                    }
                }
            })
            
            let tryAgainSection = TableSection(rows: [tryAgainRow])
            sections.append(tryAgainSection)
            
            if let relatedLinksSection = relatedLinksSection() {
                sections.append(relatedLinksSection)
            }
            
            data = sections
            
        } else {
            
            if let relatedLinksSection = relatedLinksSection() {
                
                data = [relatedLinksSection]
                return
            }
            
            tableView.isScrollEnabled = true
            let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 300)
            let image = quiz.badge?.icon
            
            if let achievementDisplayViewClass = StormObjectFactory.shared.class(for:  String(describing: AchievementDisplayView.self)) as? AchievementDisplayable.Type {
                
                achievementDisplayView = achievementDisplayViewClass.init(frame: frame, image: image, subtitle: winMessage) as? UIView
            }
            
            if achievementDisplayView == nil {
                achievementDisplayView = AchievementDisplayView(frame: frame, image: image, subtitle: winMessage)
            }
            
            view.addSubview(achievementDisplayView!)
                    
            markCompleted(quiz: quiz)
            NotificationCenter.default.post(name: QUIZ_COMPLETED_NOTIFICATION, object: nil)
        }
        
        NotificationCenter.default.sendAnalyticsScreenView(
            Analytics.ScreenView(
                screenName: quiz.answeredCorrectly ? "quiz_complete" : "quiz_failed",
                navigationController: navigationController
            )
        )
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLeftNavigationBarButtons()
        
        if !hasPoppedIn {
            achievementDisplayView?.popIn()
            hasPoppedIn = true
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // ARCFA-329: require that the first element starts reading on voice
        // over when the user goes to this page, force it here.
        guard !quiz.answeredCorrectly,
            UIAccessibility.isVoiceOverRunning,
            let cell = tableView.cellForRow(
                at: IndexPath(row: 0, section: 0)
            ) else {
                return
        }
        UIAccessibility.post(notification: .screenChanged, argument: cell)
    }
    
    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        achievementDisplayView?.frame = view.bounds
    }
    
    //MARK: -
    //MARK: Helper methods
    //MARK: -
    
    private func relatedLinksSection() -> TableSection? {
        
        let links = quiz.answeredCorrectly ? quiz.winRelatedLinks : quiz.loseRelatedLinks
        guard let relatedLinks = links, !relatedLinks.isEmpty else { return nil }
        
        let linkRows: [Row] = relatedLinks.compactMap { (link) -> Row? in
            
            guard var linkRow = row(for: link, quizCorrect: quiz.answeredCorrectly) else { return nil }
            
            if let row = linkRow as? TableRow {
                row.selectionHandler = { (row, wasSelection, indexPath, tableView) -> (Void) in
                    self.navigationController?.push(link: link)
                }
                linkRow = row
            }
            
            return linkRow
        }
        
        if linkRows.count > 0 {
            return TableSection(rows: linkRows, header: "Related Links".localised(with: "_QUIZ_COMPLETION_TITLE_LINKS"), footer: nil, selectionHandler: nil)
        }
        
        return nil
    }
    
    private func setupLeftNavigationBarButtons() {
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            
            var leftItems: [UIBarButtonItem] = []
            
            if quiz.answeredCorrectly, let additionalLeftItems = additionalLeftBarButtonItems {
                leftItems.append(contentsOf: additionalLeftItems)
            }
            
            navigationItem.leftBarButtonItems = leftItems.count > 0 ? leftItems : nil
        }
    }
    
    open override func accessibilitySettingsDidChange() {
        
        guard let achievementView = achievementDisplayView as? AchievementDisplayView else {
            return
        }
        achievementView.accessibilitySettingsDidChange()
    }
    
    //MARK: -
    //MARK: Bar Button actions
    //MARK: -
    
    /// This method is called when the user clicks to share the badge related to this quiz
    ///
    /// - Parameter sender: The button which the user hit to share the badge
    @objc open func shareBadge(sender: Any) {
        guard let badge = quiz.badge else { return }
        guard let sourceView = ShareSourceView(sender: sender) else { return }

        presentShare(
            badge,
            defaultShareMessage: "I earned this badge".localised(with: "_TEST_COMPLETED_SHARE"),
            sourceView: sourceView
        ) { activityType, completed, _, _ in
            NotificationCenter.default.sendAnalyticsHook(
                .testShare(self.quiz, activityType, completed)
            )
        }
    }
    
    /// This method is called when the user clicks to dismiss the quiz completion view
    ///
    /// - Parameter sender: The button which the user hit to dismiss the view
    @objc open func finishQuiz(sender: Any) {
        
        navigationController?.navigationBar.isTranslucent = false
        
        if presentingViewController != nil {
            dismissAnimated()
        } else {
            
            let quizCompletionClass: AnyClass = StormObjectFactory.shared.class(for: String(describing: QuizCompletionViewController.self)) ?? QuizCompletionViewController.self
            var questionContainerClass: AnyClass?
            if let questionVC = quiz.questionViewController() {
                questionContainerClass = type(of: questionVC)
            }
            
            popToLastViewController(excluding: [
                questionContainerClass ?? QuizQuestionContainerViewController.self,
                quizCompletionClass
                ], excludeSubclasses: true, animated: true)
        }
        
        // Important to call this last
        quiz.restart()
    }
    
    //MARK: -
    //MARK: Quiz handling
    //MARK: -
    
    private func markCompleted(quiz: Quiz) {
        guard let badge = quiz.badge else {
            return
        }
        
        BadgeController.shared.mark(badge: badge, earnt: true)
        
        if let achievementDisplayView = achievementDisplayView as? AchievementDisplayView {
            achievementDisplayView.expirableAchievement = quiz.badge?.expirableAchievement
        } 
        
        // Note for PR or if you're expecting the rate the app popup here. This has been removed
        // as Apple no longer allow custom pop-ups to rate apps.
    }
}

//MARK: -
//MARK: - UITableViewDataSource
//MARK: -
extension QuizCompletionViewController {
    override open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if !quiz.answeredCorrectly {
            return UITableView.automaticDimension
        }
        
        guard let winRelatedLinks = quiz.winRelatedLinks, !winRelatedLinks.isEmpty else {
            return 256
        }
        
        return UITableView.automaticDimension
    }
}
