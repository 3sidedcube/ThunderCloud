//
//  SpotlightImageListItemViewCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 03/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

public class SpotlightImageCollectionViewCell: UICollectionViewCell {
	
	@IBOutlet public weak var imageView: UIImageView!
	
	@IBOutlet public weak var titleLabel: UILabel!
	
	@IBOutlet public weak var textShadowImageView: UIImageView!
}

public protocol SpotlightListItemCellDelegate: class {
	func spotlightCell(cell: SpotlightListItemCell, didReceiveTapOnItem atIndex: Int)
}

open class SpotlightListItemCell: StormTableViewCell {

	@IBOutlet private weak var collectionView: UICollectionView!
	
	@IBOutlet private weak var pageIndicator: UIPageControl!
	
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    weak var delegate: SpotlightListItemCellDelegate?
	
	var currentPage: Int = 0 {
		didSet {
			pageIndicator.currentPage = currentPage
			setSpotlightTimer()
		}
	}
	
	var spotlights: [Spotlight]? {
		didSet {
			
			if let spotLights = spotlights {
				pageIndicator.isHidden = spotLights.count < 2
			}
			pageIndicator.numberOfPages = spotlights?.count ?? 0
			collectionView.reloadData()
		}
	}
	
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonSetup()
    }
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override open func awakeFromNib() {
		super.awakeFromNib()
		commonSetup()
	}
	
	private func commonSetup() {
		
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.scrollsToTop = false
		let nib = UINib(nibName: "SpotlightImageCollectionViewCell", bundle: Bundle(for: SpotlightListItemCell.self))
		collectionView.register(nib, forCellWithReuseIdentifier: "SpotlightCell")
		
		pageIndicator.isUserInteractionEnabled = false
	}
	
	override open func layoutSubviews() {
		super.layoutSubviews()
		collectionView.collectionViewLayout.invalidateLayout()
		setSpotlightTimer()
	}
	
	@IBAction func handlePageControl(_ sender: Any) {
		
	}
	
	private var spotlightCycleTimer: Timer?
	
	private func setSpotlightTimer() {
		
		guard let spotlights = spotlights, spotlights.count > currentPage else {
			return
		}
		
		let delay = currentPage < spotlights.count ? spotlights[currentPage].delay ?? 5 : 5
		
		if delay != 0 {
			spotlightCycleTimer?.invalidate()
			spotlightCycleTimer = Timer.scheduledTimer(timeInterval: TimeInterval(delay), target: self, selector: #selector(cycleSpotlight(timer:)), userInfo: nil, repeats: false)
		}
	}
	
	@objc func cycleSpotlight(timer: Timer) {
		
		if pageIndicator.currentPage + 1 == pageIndicator.numberOfPages {
			
			let firstIndex = IndexPath(item: 0, section: 0)
			collectionView.scrollToItem(at: firstIndex, at: .left, animated: true)
			currentPage = 0
			
		} else {
			
			let nextIndex = IndexPath(item: currentPage + 1, section: 0)
			collectionView.scrollToItem(at: nextIndex, at: .left, animated: true)
			currentPage = currentPage + 1
		}
	}
	
	open func configure(spotlightCell: SpotlightImageCollectionViewCell, with spotlight: Spotlight) {
		
		spotlightCell.imageView.image = spotlight.image
		spotlightCell.titleLabel.text = spotlight.spotlightText
		spotlightCell.titleLabel.font = ThemeManager.shared.theme.boldFont(ofSize: 22)
		spotlightCell.titleLabel.shadowColor = UIColor.black.withAlphaComponent(0.5)
		spotlightCell.titleLabel.shadowOffset = CGSize(width: 0, height: 1)
		
		spotlightCell.textShadowImageView.isHidden = spotlightCell.titleLabel.text == nil || spotlightCell.titleLabel.text!.isEmpty
	}
}

//MARK: UICollectionViewDelegateFlowLayout methods
extension SpotlightListItemCell: UICollectionViewDelegateFlowLayout {
	
	public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: bounds.size.width, height: bounds.size.height)
	}
	
	public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		delegate?.spotlightCell(cell: self, didReceiveTapOnItem: indexPath.item)
	}
}

//MARK: UICollectionViewDataSource methods
extension SpotlightListItemCell: UICollectionViewDataSource {
	
	public func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return spotlights?.count ?? 0
	}
	
	public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpotlightCell", for: indexPath)
			
		guard let spotlightCell = cell as? SpotlightImageCollectionViewCell, let spotlight = spotlights?[indexPath.item] else {
			return cell
		}
		
		configure(spotlightCell: spotlightCell, with: spotlight)
		
		return spotlightCell
	}
	
	public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}
	
	public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}
}

//MARK: UIScrollViewDelegate methods
extension SpotlightListItemCell: UIScrollViewDelegate {
	
	public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		
		let page = scrollView.contentOffset.x / scrollView.frame.width
		currentPage = Int(page)
	}
}
