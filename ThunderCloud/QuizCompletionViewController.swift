//
//  QuizCompletionViewController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 03/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

public let OPEN_NEXT_QUIZ_NOTIFICATION = NSNotification.Name.init("OPEN_NEXT_QUIZ_NOTIFICATION")
public let QUIZ_COMPLETED_NOTIFICATION = NSNotification.Name.init("QUIZ_COMPLETED_NOTIFICATION")

extension Quiz {
	public var badge: Badge? {
		guard let badgeId = badgeId else { return nil }
		return BadgeController.shared.badge(for: badgeId)
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
		return NumberedViewCell.self
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
		
		// We have no links so make sure to get rid of the spacing on mainStackView
		numberCell.mainStackView?.spacing = 0
	}
	
	public var accessoryType: UITableViewCellAccessoryType? {
		return UITableViewCellAccessoryType.none
	}
	
	public var selectionStyle: UITableViewCellSelectionStyle? {
		return UITableViewCellSelectionStyle.none
	}
}

/// A view which will be shown to the user upon them answering all of the questions in a quiz
///
/// This view will calculate whether the user has answered the quiz correctly and display either hints on which questions a user answered incorrectly, or display a congratulatory view
///
/// This class will also send out `NotificationCenter` notifications to alert other views that the user has completed a quiz
@objc(TSCQuizCompletionViewController)
open class QuizCompletionViewController: TableViewController {
	
	//MARK: -
	//MARK: Declarations
	//MARK: -
	
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
	
	/// Returns a table row for a link related to the completed quiz
	///
	/// This may, for example, contain a link to a token or sale if a user has correctly answered the quiz
	///
	/// - Parameters:
	///   - relatedLink: The link which the row should take the user to upon selection
	///   - quizCorrect: Whether the user completed the quiz correctly
	/// - Returns: An object conforming to `Row` protocol
	open func row(for relatedLink: StormLink, quizCorrect: Bool) -> Row? {
		return TableRow(title: relatedLink.title)
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
		
		title = quiz.title
		navigationItem.setHidesBackButton(true, animated: true)
		
		if UI_USER_INTERFACE_IDIOM() == .pad, let splitViewController = UIApplication.shared.keyWindow?.rootViewController as? SplitViewController {
			//TODO: Add back in!
//			navigationItem.leftBarButtonItem = splitViewController.open
		}
		
		if quiz.answeredCorrectly {
			
			navigationItem.leftBarButtonItems = additionalLeftBarButtonItems
			setupLeftNavigationBarButtons()
			
			NotificationCenter.default.sendStatEventNotification(category: "Quiz", action: "Won \(quiz.title ?? "Unkown") badge)", label: nil, value: nil, object: self)
		} else {
			
			NotificationCenter.default.sendStatEventNotification(category: "Quiz", action: "Lost \(quiz.title ?? "Unkown") badge)", label: nil, value: nil, object: self)
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
						
						NotificationCenter.default.sendStatEventNotification(category: "Quiz", action: "Try again - \(self.quiz.title ?? "Unknown")", label: nil, value: nil, object: self)
						
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

			if let achievementDisplayViewClass = StormObjectFactory.shared.class(for:  NSStringFromClass(AchievementDisplayView.self)) as? AchievementDisplayable.Type {
				
				achievementDisplayView = achievementDisplayViewClass.init(frame: frame, image: image, subtitle: quiz.winMessage) as? UIView
			}
			
			if achievementDisplayView == nil {
				achievementDisplayView = AchievementDisplayView(frame: frame, image: image, subtitle: quiz.winMessage)
			}
			
			view.addSubview(achievementDisplayView!)
		}
		
		tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
	}
	
	override open func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupLeftNavigationBarButtons()
		achievementDisplayView?.popIn()
	}
	
	override open func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		guard quiz.answeredCorrectly else { return }
			
		// Must occur in this order
		markCompleted(quiz: quiz)
		NotificationCenter.default.post(name: QUIZ_COMPLETED_NOTIFICATION, object: nil)
	}
	
	override open func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		achievementDisplayView?.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 400)
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
			
			// TODO: Add back in!
//			if self.presentingViewController == nil, let menuButton = TSCSplitViewController.shared().menuButton {
//				
//				leftItems.append(menuButton)
//				let fixedItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
//				fixedItem.width = 20
//				leftItems.append(fixedItem)
//			}
			
			if quiz.answeredCorrectly, let additionalLeftItems = additionalLeftBarButtonItems {
				leftItems.append(contentsOf: additionalLeftItems)
			}
			
			navigationItem.leftBarButtonItems = leftItems.count > 0 ? leftItems : nil
		}
	}
	
	//MARK: -
	//MARK: Bar Button actions
	//MARK: -
	
	/// This method is called when the user clicks to share the badge related to this quiz
	///
	/// - Parameter sender: The button which the user hit to share the badge
	@objc open func shareBadge(sender: Any) {
		
		let defaultShareMessage = "I earned this badge".localised(with: "_TEST_COMPLETED_SHARE")
		var items: [Any] = []
		
		if let image = quiz.badge?.icon {
			items.append(image)
		}
		
		items.append(quiz.badge?.shareMessage ?? defaultShareMessage)
		
		let shareViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
		shareViewController.excludedActivityTypes = [.saveToCameraRoll, .print, .assignToContact]
		
		shareViewController.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
		
		shareViewController.completionWithItemsHandler = { (activityType, didComplete, returnedItems, activityError) -> (Void) in
			
			if didComplete {
				NotificationCenter.default.sendStatEventNotification(category: "Quiz", action: "Share \(self.quiz.title ?? "Unknown") to \(activityType?.rawValue ?? "Unknown")", label: nil, value: nil, object: self)
			}
		}
		
		present(shareViewController, animated: true, completion: nil)
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
		
		if quiz.answeredCorrectly {
			NotificationCenter.default.post(name: QUIZ_COMPLETED_NOTIFICATION, object: nil)
		}
		
		// Important to call this last
		quiz.restart()
	}
	
	//MARK: -
	//MARK: Quiz handling
	//MARK: -
	
	private func markCompleted(quiz: Quiz) {
		
		if let badge = quiz.badge {
			BadgeController.shared.mark(badge: badge, earnt: true)
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
			return UITableViewAutomaticDimension
		}
		
		guard let winRelatedLinks = quiz.winRelatedLinks, !winRelatedLinks.isEmpty else {
			return 256
		}
		
		return UITableViewAutomaticDimension
	}
}
