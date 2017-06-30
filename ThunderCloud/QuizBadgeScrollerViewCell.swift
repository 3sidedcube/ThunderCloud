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
	open var badges: [TSCBadge]?
	
	/// An array of `TSCQuizPage`s which are pushed onto screen when a badge is selected
	open var quizzes: [TSCQuizPage]?
	
	/// This is called when a badge is clicked.
	///
	/// It gets the relevant quiz for the badge and pushes a `TSCQuizPage` on to the screen.
	/// If a badge has been completed, it pushes the quizzes completion page
	///
	/// - Parameter atIndexPath: The IndexPath of the selected collection view cell
	open func handleSelectedQuiz(atIndexPath: IndexPath) {
		
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		collectionView.register(TSCQuizBadgeScrollerItemViewCell.self, forCellWithReuseIdentifier: "Cell")
		
		//TODO: Replace with actual object rather than string
		NotificationCenter.default.addObserver(self, selector: #selector(reload), name: NSNotification.Name.init(rawValue: "QUIZ_COMPLETED_NOTIFICATION"), object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(reload), name: NSNotification.Name.init(rawValue: "BADGES_CLEARED_NOTIFICATION"), object: nil)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init(rawValue: "QUIZ_COMPLETED_NOTIFICATION"), object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init(rawValue: "BADGES_CLEARED_NOTIFICATION"), object: nil)
	}
	
	open override func layoutSubviews() {
		super.layoutSubviews()
		
		collectionView.frame = CGRect(x: 0, y: 0, width: <#T##CGFloat#>, height: <#T##CGFloat#>)
	}
}
