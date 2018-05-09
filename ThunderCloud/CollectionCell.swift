//
//  CollectionCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 30/06/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation
import ThunderTable

/// A subclass of `StormTableViewCell` which displays the user a collection view
open class CollectionCell: StormTableViewCell {
	
	/// The collection view used to display the list of items
	@IBOutlet public var collectionView: UICollectionView!
	
	/// A paging control showing how many pages of apps the user can scroll through
	@IBOutlet public var pageControl: UIPageControl!
	
	/// The `UICollectionViewFlowLayout` of the cells collection view
	open var collectionViewLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
	
	fileprivate var currentPage: Int = 0 {
		didSet {
			pageControl.currentPage = currentPage
		}
	}
	
	/// Reloads the collection view of the TSCCollectionCell
	@objc open func reload() {
		collectionView.reloadData()
		if collectionView.frame.width > 0 {
			pageControl.numberOfPages = Int(ceil(collectionView.contentSize.width / collectionView.frame.width))
		}
	}
	
	deinit {
		collectionView.removeObserver(self, forKeyPath: "contentSize")
	}
	
	override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		let bgImage = UIImage(named: "TSCPortalViewCell-bg")?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
		backgroundView = UIImageView(image: bgImage)
		contentView.addSubview(backgroundView!)
		
		collectionViewLayout.scrollDirection = .horizontal
		
		collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
		contentView.addSubview(collectionView)
		
		pageControl = UIPageControl(frame: CGRect(x: 0, y: frame.height - 17, width: frame.width, height: 16))
		contentView.addSubview(pageControl)
		
		sharedInit()
	}
	
	private var nibBased = false
	
	override open func awakeFromNib() {
		super.awakeFromNib()
		sharedInit()
		nibBased = true
	}
	
	required public init?(coder aDecoder: NSCoder) {

		super.init(coder: aDecoder)
		sharedInit()
	}
	
	private func sharedInit() {
        
        guard let pageControl = pageControl, let collectionView = collectionView else { return }
		
		pageControl.currentPage = 0
		pageControl.pageIndicatorTintColor = .lightGray
		pageControl.currentPageIndicatorTintColor = ThemeManager.shared.theme.mainColor
		pageControl.isUserInteractionEnabled = false
		
		collectionView.delegate = self
		collectionView.dataSource = self
		collectionView.backgroundColor = .clear
		collectionView.alwaysBounceHorizontal = true
		collectionView.isPagingEnabled = true
		collectionView.showsHorizontalScrollIndicator = false
		
		collectionView.addObserver(self, forKeyPath: "contentSize", options: [.new], context: nil)
	}
	
	override open func layoutSubviews() {
		
		super.layoutSubviews()
		
		if !nibBased {
			
			collectionView.frame = bounds
			pageControl.frame = CGRect(x: 0, y: bounds.height - 17, width: bounds.width, height: 12)
		}
		
		if collectionView.frame.width > 0 {
			pageControl.numberOfPages = Int(ceil(collectionView.contentSize.width / collectionView.frame.width))
		}
	}
	
	override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		
		if collectionView.frame.width > 0 {
			pageControl.numberOfPages = Int(ceil(collectionView.contentSize.width / collectionView.frame.width))
		}
	}
}

extension CollectionCell : UICollectionViewDelegateFlowLayout {
	public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let page = scrollView.contentOffset.x / scrollView.frame.size.width
		currentPage = Int(ceil(page))
	}
}

extension CollectionCell : UICollectionViewDataSource {
	
	open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 0
	}
	
	open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		return collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
	}
}
