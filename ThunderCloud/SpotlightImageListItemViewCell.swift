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
	
	
}

@objc(TSCSpotlightImageListItemViewCell)
class SpotlightImageListItemViewCell: TableViewCell {

	@IBOutlet private weak var collectionView: UICollectionView!
	
	@IBOutlet private weak var pageIndicator: UIPageControl!
	
	var spotlights: [TSCSpotlight]? {
		didSet {
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
}

//MARK: UICollectionViewDelegateFlowLayout methods
extension SpotlightImageListItemViewCell: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: bounds.size.width, height: bounds.size.height)
	}
}

//MARK: UICollectionViewDataSource methods
extension SpotlightImageListItemViewCell: UICollectionViewDataSource {
	
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
		
		return spotlightCell
	}
}

//MARK: UIScrollViewDelegate methods
extension SpotlightImageListItemViewCell: UIScrollViewDelegate {
	
}
