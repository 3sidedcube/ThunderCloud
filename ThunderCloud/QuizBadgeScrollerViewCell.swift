//
//  QuizBadgeScrollerViewCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 30/06/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation

private class BadgeScrollerFlowLayout: UICollectionViewFlowLayout {
	override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
		return CGPoint(x: proposedContentOffset.x - 100.0, y: proposedContentOffset.y)
	}
}

@objc(TSCQuizBadgeScrollerViewCell)
/// `QuizBadgeScrollerViewCell` is a `TableViewCell` with a `UICollectionView` inside of it.
/// It is used to display all of the badges in a single cell.
open class QuizBadgeScrollerViewCell: CollectionCell {
	
	/// An array of `TSCBadge`s to be displayed in the collection view
	open var badges: [TSCBadge]? {
		didSet {
			reload()
		}
	}
	
	/// An array of `TSCQuizPage`s which are pushed onto screen when a badge is selected
	open var quizzes: [TSCQuizPage]?
	
	/// This is called when a badge is clicked.
	///
	/// It gets the relevant quiz for the badge and pushes a `TSCQuizPage` on to the screen.
	/// If a badge has been completed, it pushes the quizzes completion page
	///
	/// - Parameter atIndexPath: The IndexPath of the selected collection view cell
	open func handleSelectedQuiz(atIndexPath: IndexPath) {
		
		guard let _badges = badges else { return }
		let badge = _badges[atIndexPath.row]
		
		if TSCBadgeController.shared().hasEarntBadge(withId: badge.badgeId) {
			
			let defaultShareBadgeMessage = "Test Completed".localised(with: "_TEST_COMPLETED_SHARE")
			var items: [Any] = []
			
			if let badgeIcon = badge.badgeIcon, let image = TSCImage.image(withJSONObject: badgeIcon as NSObject) {
				items.append(image)
			}
			
			items.append(badge.badgeShareMessage ?? defaultShareBadgeMessage)
			
			let shareViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
			
			if let keyWindow = UIApplication.shared.keyWindow {
				
				shareViewController.popoverPresentationController?.sourceView = keyWindow
				shareViewController.popoverPresentationController?.sourceRect = CGRect(x: keyWindow.center.x, y: keyWindow.frame.maxY, width: 100, height: 100)
				shareViewController.popoverPresentationController?.permittedArrowDirections = [.up]
			}
			
			NotificationCenter.default.post(
				name: NSNotification.Name.init(rawValue: "TSCStatEventNotification"),
				object: self,
				userInfo: [
					"type": "event",
					"category": "Badge",
					"action": "Shared \(badge.badgeTitle ?? "Unknown") badge"
				]
			)
			
			if TSC_isPad() {
				TSCSplitViewController.shared().presentFullScreenViewController(shareViewController, animated: true)
			} else {
				parentViewController?.presentViewController(shareViewController, animated: false, completion: nil)
			}
		} else {
			
			guard let quiz = quizzes?.first(where: { (quizPage) -> Bool in
				
				guard let id = quizPage.quizBadge.badgeId, let testId = badge.badgeId else { return false }
				return id == testId
			}) else {
				return
			}
					
			quiz.resetInitialPage()
			
			if TSC_isPad() {
				
				let quizNavigationController = UINavigationController(rootViewController: quiz)
				quizNavigationController.modalPresentationStyle = .formSheet
				let visibleViewController = UIApplication.shared.keyWindow?.visibleViewController
				
				if let navigatationController = visibleViewController?.navigationController, visibleViewController?.presentingViewController != nil {
					
					navigatationController.pushViewController(quiz, animated: true)
					
				} else if let _ = UIApplication.shared.keyWindow?.rootViewController as? TSCSplitViewController {
					
					TSCSplitViewController.shared().setRight(quiz, from: parentViewController?.navigationController)
				} else {
					
					parentViewController?.navigationController?.present(quiz, animated: true)
				}
				
			} else {
				
				quiz.hidesBottomBarWhenPushed = true
				parentViewController?.navigationController?.pushViewController(quiz, animated: true)
			}
		}
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		collectionView.register(TSCQuizBadgeScrollerItemViewCell.self, forCellWithReuseIdentifier: "Cell")
		
		NotificationCenter.default.addObserver(self, selector: #selector(reload), name: QUIZ_COMPLETED_NOTIFICATION, object: nil)
		
		//TODO: Replace with actual object rather than string
		NotificationCenter.default.addObserver(self, selector: #selector(reload), name: NSNotification.Name.init(rawValue: BADGES_CLEARED_NOTIFICATION), object: nil)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		
		NotificationCenter.default.removeObserver(self, name: QUIZ_COMPLETED_NOTIFICATION, object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init(rawValue: BADGES_CLEARED_NOTIFICATION), object: nil)
	}
	
	open override func layoutSubviews() {
		super.layoutSubviews()
		
		collectionView.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
		pageControl.frame = CGRect(x: 0, y: contentView.frame.height - 24, width: contentView.frame.width, height: 20)
		pageControl.numberOfPages = Int(ceil(collectionView.contentSize.width / collectionView.frame.width))
	}
}

//MARK: Collection view layout delegate
extension QuizBadgeScrollerViewCell {
	public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return badges?.count == 0 ? CGSize(width: bounds.size.width, height: bounds.size.height + 10) : CGSize(width: bounds.size.width/floor(bounds.size.width/120), height: bounds.size.height + 10)
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
	
	public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.badges?.count ?? 0
	}
	
	public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
		
		guard let badge = badges?[indexPath.item], let badgeCell = cell as? TSCQuizBadgeScrollerItemViewCell else {
			return cell
		}
		
		if let imageObject = badge.badgeIcon {
			badgeCell.badgeImage.image = TSCImage.image(withJSONObject: imageObject as NSObject)
		} else {
			badgeCell.badgeImage.image = nil
		}
		
		badgeCell.titleLabel.text = badge.badgeTitle
		
		if let badgeId = badge.badgeId, TSCBadgeController.shared().hasEarntBadge(withId:badgeId) {
			badgeCell.completed = true
		} else {
			badgeCell.completed = false
		}
		
		badgeCell.layoutSubviews()
		
		return badgeCell
	}
}
