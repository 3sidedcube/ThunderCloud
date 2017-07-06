//
//  SpotlightImageListItemViewCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 03/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

class SpotlightImageCollectionViewCell: UICollectionViewCell {
	
	@IBOutlet weak var imageView: UIImageView!
	
	@IBOutlet weak var titleLabel: UILabel!
	
	@IBOutlet weak var textShadowImageView: UIImageView!
}

protocol SpotlightListItemCellDelegate {
	func spotlightCell(cell: SpotlightListItemCell, didReceiveTapOnItem atIndex: Int)
}

@objc(TSCSpotlightListItemCell)
class SpotlightListItemCell: TableViewCell {

	@IBOutlet private weak var collectionView: UICollectionView!
	
	@IBOutlet private weak var pageIndicator: UIPageControl!
	
	var delegate: SpotlightListItemCellDelegate?
	
	var currentPage: Int = 0 {
		didSet {
			pageIndicator.currentPage = currentPage
			setSpotlightTimer()
		}
	}
	
	var spotlights: [Spotlight]? {
		didSet {
			if let _spotLights = spotlights {
				pageIndicator.isHidden = _spotLights.count < 2
			}
			collectionView.reloadData()
		}
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		commonSetup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		commonSetup()
	}
	
	private func commonSetup() {
		
		collectionView.delegate = self
		collectionView.scrollsToTop = false
		collectionView.register(SpotlightImageCollectionViewCell.self, forCellWithReuseIdentifier: "SpotlightCell")
		
		pageIndicator.isUserInteractionEnabled = false
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		collectionView.collectionViewLayout.invalidateLayout()
	}
	
	@IBAction func handlePageControl(_ sender: Any) {
		
	}
	
	private var spotlightCycleTimer: Timer?
	
	private func setSpotlightTimer() {
		
		guard let _spotlights = spotlights, _spotlights.count > currentPage else {
			return
		}
		
		let delay = currentPage < _spotlights.count ? _spotlights[currentPage].delay ?? 5 : 5
		
		if delay != 0 {
			spotlightCycleTimer?.invalidate()
			spotlightCycleTimer = Timer.scheduledTimer(timeInterval: TimeInterval(delay), target: self, selector: #selector(cycleSpotlight(timer:)), userInfo: nil, repeats: false)
		}
	}
	
	func cycleSpotlight(timer: Timer) {
		
		if pageIndicator.currentPage + 1 == pageIndicator.numberOfPages {
			
			let firstIndex = IndexPath(item: 0, section: 0)
			collectionView.scrollToItem(at: firstIndex, at: .left, animated: true)
			currentPage = 0
			
		} else {
			
			let nextRect = CGRect(x: collectionView.contentOffset.x + collectionView.bounds.width, y: 0, width: collectionView.frame.width, height: collectionView.frame.height)
			collectionView.scrollRectToVisible(nextRect, animated: true)
			currentPage = currentPage + 1
		}
	}
}

//MARK: UICollectionViewDelegateFlowLayout methods
extension SpotlightListItemCell: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: bounds.size.width, height: bounds.size.height)
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		delegate?.spotlightCell(cell: self, didReceiveTapOnItem: indexPath.item)
	}
}

//MARK: UICollectionViewDataSource methods
extension SpotlightListItemCell: UICollectionViewDataSource {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return spotlights?.count ?? 0
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpotlightCell", for: indexPath)
			
		guard let spotlightCell = cell as? SpotlightImageCollectionViewCell, let spotlight = spotlights?[indexPath.row] else {
			return cell
		}
		
		spotlightCell.imageView.image = spotlight.image
		spotlightCell.titleLabel.text = spotlight.spotlightText
		spotlightCell.titleLabel.font = ThemeManager.shared.theme.boldFont(ofSize: 22)
		spotlightCell.titleLabel.shadowColor = UIColor.black.withAlphaComponent(0.5)
		spotlightCell.titleLabel.shadowOffset = CGSize(width: 0, height: 1)
		
		spotlightCell.textShadowImageView.isHidden = spotlightCell.titleLabel.text == nil || spotlightCell.titleLabel.text!.isEmpty
		
		return spotlightCell
	}
}

//MARK: UIScrollViewDelegate methods
extension SpotlightListItemCell: UIScrollViewDelegate {
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		
		let page = scrollView.contentOffset.x / scrollView.frame.width
		currentPage = Int(page)
	}
}
