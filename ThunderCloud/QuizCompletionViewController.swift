//
//  QuizCompletionViewController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 03/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

public let OPEN_NEXT_QUIZ_NOTIFICATION = NSNotification.Name.init("OPEN_NEXT_QUIZ_NOTIFICATION")
public let QUIZ_COMPLETED_NOTIFICATION = NSNotification.Name.init("QUIZ_COMPLETED_NOTIFICATION")

extension TSCQuizItem: Row {
	
	public var title: String? {
		return isCorrect ? "Correct".localised(with: "_TEST_CORRECT") : questionText
	}
	
	public var subtitle: String? {
		return isCorrect ? winText : failureText
	}
	
	public var cellClass: AnyClass? {
		return NumberedViewCell.self
	}
	
	public func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		
		guard let numberCell = cell as? NumberedViewCell else { return }
		numberCell.numberLabel.text = "\(questionNumber)"
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
	public var additionalLeftBarButtonItems: [UIBarButtonItem]? = [
		UIBarButtonItem(
			title: "Share".localised(with: "_QUIZ_BUTTON_SHARE"),
			style: .plain,
			target: self,
			action: #selector(shareBadge(sender:)))
	]
	
	/// The button to be displayed to the user on the right of the navigation bar
	///
	/// Defaults to a button to finish the quiz
	public var rightBarButtonItem: UIBarButtonItem? {
		get {
			if let _ = UIApplication.shared.keyWindow?.rootViewController as? TSCSplitViewController, self.presentingViewController == nil && navigationController?.viewControllers.count == quizPage.questions.count + 1 {
				return nil
			}
			
			return UIBarButtonItem(
				title: "Finish".localised(with: "_QUIZ_BUTTON_FINISH"),
				style: .plain,
				target: self,
				action: #selector(finishQuiz(sender:)))
		}
	}
	
	/// Whether the quiz was answered correctly or not
	public var quizIsCorrect: Bool
	
	/// A handler to be called when a user selects to retry the quiz
	///
	/// If provided this will override the default behaviour of `QuizCompletionViewController`
	public var retryHandler: SelectionHandler?
	
	/// The questions which the user answered
	public let questions: [TSCQuizItem]
	
	/// The quiz page the user has just come from
	public let quizPage: TSCQuizPage
	
	/// Returns a table row for a link related to the completed quiz
	///
	/// This may, for example, contain a link to a token or sale if a user has correctly answered the quiz
	///
	/// - Parameters:
	///   - relatedLink: The link which the row should take the user to upon selection
	///   - quizCorrect: Whether the user completed the quiz correctly
	/// - Returns: An object conforming to `Row` protocol
	open func row(for relatedLink: TSCLink, quizCorrect: Bool) -> Row? {
		return TableRow(title: relatedLink.title)
	}

	//MARK: -
	//MARK: View Controller Lifecycle
	//MARK: -
	
	/// Creates a new completion screen with the `TSCQuizPage which the user has just completed
	/// and the array of questions they have just answered
	///
	/// - Parameters:
	///   - quizPage: The quiz page the user has just come from / completed
	///   - questions: The array of quiz questions the user has just answered
	public init(quizPage: TSCQuizPage, questions: [TSCQuizItem]) {
		
		self.quizPage = quizPage
		self.questions = questions
		
		quizIsCorrect =  questions.filter({ (item) -> Bool in
			item.isCorrect
		}).count == questions.count
		
		super.init(style: .plain)
		
		title = quizPage.title
		navigationItem.setHidesBackButton(true, animated: true)
		
		if UI_USER_INTERFACE_IDIOM() == .pad {
			navigationItem.leftBarButtonItem = TSCSplitViewController.shared().menuButton
		}
		
		if quizIsCorrect {
			
			navigationItem.leftBarButtonItems = additionalLeftBarButtonItems
			setupLeftNavigationBarButtons()
			
			NotificationCenter.default.sendStatEventNotification(category: "Quiz", action: "Won \(quizPage.title ?? "Unkown") badge)", label: nil, value: nil, object: self)
		} else {
			
			NotificationCenter.default.sendStatEventNotification(category: "Quiz", action: "Lost \(quizPage.title ?? "Unkown") badge)", label: nil, value: nil, object: self)
		}
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private var achievementDisplayView: UIView?
	
	open override func viewDidLoad() {
		
		super.viewDidLoad()
		
		navigationItem.rightBarButtonItem = rightBarButtonItem
		tableView.backgroundColor = ThemeManager.shared.theme.backgroundColor
		
		if !quizIsCorrect {
			
			var sections: [Section] = []
			
			if let loseMessage = quizPage.loseMessage {
				
				let failRow = StormTableRow(title: loseMessage)
				let failSection = TableSection(rows: [failRow])
				sections.append(failSection)
			}
			
			let questionSection = TableSection(rows: questions)
			sections.append(questionSection)
			
			let tryAgainRow = StormTableRow(title: "Try again?".localised(with: "_QUIZ_BUTTON_AGAIN"), subtitle: nil, image: nil, selectionHandler: { (row, selected, indexPath, tableView) -> (Void) in
				
				if selected {
					
					if let _retry = self.retryHandler {
						
						_retry(row, selected, indexPath, tableView)
						
					} else {
						
						NotificationCenter.default.sendStatEventNotification(category: "Quiz", action: "Try again - \(self.quizPage.title ?? "Unknown")", label: nil, value: nil, object: self)
						
						guard let quizId = self.quizPage.quizId, let link = TSCLink(stormPageId: quizId) else { return }
						self.navigationController?.push(link)
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
			var image: UIImage?
			if let badgeIcon = quizPage.quizBadge.badgeIcon {
				image = TSCImage.image(withJSONObject: badgeIcon as NSObject)
			}
			
			if let achievementDisplayViewClass = StormObjectFactory.shared.class(for:  NSStringFromClass(AchievementDisplayView.self)) as? AchievementDisplayable.Type {
				
				achievementDisplayView = achievementDisplayViewClass.init(frame: frame, image: image, subtitle: quizPage.winMessage) as? UIView
			}
			
			if achievementDisplayView == nil {
				achievementDisplayView = AchievementDisplayView(frame: frame, image: image, subtitle: quizPage.winMessage)
			}
			
			view.addSubview(achievementDisplayView!)
		}
		
		tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
	}
	
	open override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupLeftNavigationBarButtons()
		achievementDisplayView?.popIn()
	}
	
	open override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if quizIsCorrect {
			
			// Must occur in this order
			markCompleted(quiz: quizPage)
			NotificationCenter.default.post(name: QUIZ_COMPLETED_NOTIFICATION, object: nil)
		}
	}
	
	open override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		achievementDisplayView?.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 400)
	}
	
	//MARK: -
	//MARK: Helper methods
	//MARK: -
	
	private func relatedLinksSection() -> TableSection? {
		
		let links = quizIsCorrect ? quizPage.winRelatedLinks : quizPage.loseRelatedLinks
		guard let relatedLinks = links as? [TSCLink], relatedLinks.count > 0 else { return nil }
		
		let linkRows: [Row] = relatedLinks.flatMap { (link) -> Row? in
			
			guard var linkRow = row(for: link, quizCorrect: quizIsCorrect) else { return nil }
			
			if let _row = linkRow as? TableRow {
				_row.selectionHandler = { (row, wasSelection, indexPath, tableView) -> (Void) in
					self.navigationController?.push(link)
				}
				linkRow = _row
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
			
			if self.presentingViewController == nil, let menuButton = TSCSplitViewController.shared().menuButton {
				
				leftItems.append(menuButton)
				let fixedItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
				fixedItem.width = 20
				leftItems.append(fixedItem)
			}
			
			if quizIsCorrect, let additionalLeftItems = additionalLeftBarButtonItems {
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
	open func shareBadge(sender: UIBarButtonItem) {
		
		let defaultShareMessage = "I earned this badge".localised(with: "_TEST_COMPLETED_SHARE")
		var items: [Any] = []
		
		if let imageData = quizPage.quizBadge.badgeIcon, let image = TSCImage.image(withJSONObject: imageData as NSObject) {
			items.append(image)
		}
		
		items.append(quizPage.quizBadge.badgeShareMessage ?? defaultShareMessage)
		
		let shareViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
		shareViewController.excludedActivityTypes = [.saveToCameraRoll, .print, .assignToContact]
		
		shareViewController.popoverPresentationController?.barButtonItem = sender
		
		shareViewController.completionWithItemsHandler = { (activityType, didComplete, returnedItems, activityError) -> (Void) in
			
			if didComplete {
				NotificationCenter.default.sendStatEventNotification(category: "Quiz", action: "Share \(self.quizPage.title ?? "Unknown") to \(activityType?._rawValue ?? "Unknown")", label: nil, value: nil, object: self)
			}
		}
		
		present(shareViewController, animated: true, completion: nil)
	}
	
	/// This method is called when the user clicks to dismiss the quiz completion view
	///
	/// - Parameter sender: The button which the user hit to dismiss the view
	open func finishQuiz(sender: UIBarButtonItem) {
		
		quizPage.currentIndex = 0
		navigationController?.navigationBar.isTranslucent = false
		
		if presentingViewController != nil {
			dismissAnimated()
		} else {
			navigationController?.popToRootViewController(animated: true)
		}
		
		if quizIsCorrect {
			NotificationCenter.default.post(name: QUIZ_COMPLETED_NOTIFICATION, object: nil)
		}
	}
	
	//MARK: -
	//MARK: Quiz handling
	//MARK: -
	
	private func markCompleted(quiz: TSCQuizPage) {
		
		if let badgeId = quiz.quizBadge.badgeId {
			TSCBadgeController.shared().markBadge(asEarnt: badgeId)
		}
		
		// Note for PR or if you're expecting the rate the app popup here. This has been removed
		// as Apple no longer allow custom pop-ups to rate apps.
	}
}

//MARK: -
//MARK: - UITableViewDataSource
//MARK: -
extension QuizCompletionViewController {
	open override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		
		if !quizIsCorrect {
			return UITableViewAutomaticDimension
		}
		
		guard let winRelatedLinks = quizPage.winRelatedLinks, winRelatedLinks.count > 0 else {
			return 256
		}
		
		return UITableViewAutomaticDimension
	}
}
