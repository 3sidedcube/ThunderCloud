//
//  QuizImageSelectionViewController.swift
//  GNAH
//
//  Created by Simon Mitchell on 10/08/2017.
//  Copyright © 2017 3sidedcube. All rights reserved.
//

import UIKit
import ThunderCollection

extension ImageOption: CollectionItemDisplayable {

	var collectionCellClass: AnyClass? {
		return ImageSelectionCollectionViewCell.self
	}
	
	func configure(cell: UICollectionViewCell, at indexPath: IndexPath, in tableViewController: CollectionViewController) {
		guard let imageSelectionCell = cell as? ImageSelectionCollectionViewCell else { return }
		
		imageSelectionCell.imageView.image = image
		imageSelectionCell.label.superview?.isHidden = title == nil
		imageSelectionCell.label.text = title
		
		imageSelectionCell.containerView.borderWidth = cell.isSelected ? 2 : 0
		
		imageSelectionCell.layer.shadowOffset = CGSize(width: 0, height: cell.isSelected ? 4.0 : 2.0)
	}
	
	var remainSelected: Bool {
		return true
	}
}

class QuizImageSelectionViewController: CollectionViewController {

    var question: ImageSelectionQuestion?
	
	var screenName: String?
	
	override func viewDidLoad() {
		
		// To fix an issue where isSelected is never called on off-screen cells we need to add this line, as prefetching breaks deselecting cells which are off-screen
		collectionView?.isPrefetchingEnabled = false
		
		columns = 2
		if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
			flowLayout.sectionInset = UIEdgeInsets(top: 14, left: 18, bottom: 14, right: 18)
			flowLayout.minimumLineSpacing = 22
		}
		
		collectionView?.contentInset = UIEdgeInsetsMake(0, 0, 44+32, 0)
		
		super.viewDidLoad()
		
		guard let question = question else { return }
		
		collectionView?.allowsMultipleSelection = question.limit > 1
		
		data = [
			
			CollectionSection(items: question.options, selectionHandler: { [weak self] (item, selected, indexPath, collectionView) -> (Void) in
				
				guard let strongSelf = self else { return }
				
				guard let _question = strongSelf.question else { return }
				
				if let screenName = strongSelf.screenName {
					NotificationCenter.default.sendStatEventNotification(category: screenName, action: selected ? "Select Answer" : "Deselect Answer", label: "\(indexPath.item)", value: nil, object: nil)
				}
				
				if selected {
					
					// If we've selected more answers than limit allows
					if _question.limit > 1 && _question.answer.count > _question.limit - 1, let firstAnswer = _question.answer.first {
						
						// Deselect the last selected (No need to remove it from the question object as deselect handler will do this for us)
						let removeIndexPath = IndexPath(item: firstAnswer, section: 0)
						strongSelf.collectionView?.deselectItem(at: removeIndexPath, animated: true)
						// Need to manually set it as un-selected as UIKit doesn't do this for us -.-
						if let collectionView = strongSelf.collectionView {
							strongSelf.collectionView(collectionView, didDeselectItemAt: removeIndexPath)
						}
					}
					
					// As long as it's not already selected
					if !_question.answer.contains(indexPath.item) {
						_question.answer.append(indexPath.item)
					}
					
				} else {
					
					if let removeIndex = _question.answer.index(of: indexPath.item) {
						_question.answer.remove(at: removeIndex)
					}
				}
			})
		]
	}
}
