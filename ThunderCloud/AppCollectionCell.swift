//
//  AppCollectionCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import StoreKit

@objc(TSCAppCollectionCell)
/// A subclass of `CollectionCell` which displays the user a collection of apps.
/// Apps in this collection view are displayed as their app icon, with a price and name below them
class AppCollectionCell: CollectionCell {
	
	/// The array of apps to be shown in the collection view
	var apps: [TSCAppCollectionItem]? {
		didSet {
			reload()
		}
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		let cellClass: AnyClass? = StormObjectFactory.shared.class(for: NSStringFromClass(TSCAppScrollerItemViewCell.self))
		collectionView.register(cellClass ?? TSCAppScrollerItemViewCell.self, forCellWithReuseIdentifier: "Cell")
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func layoutSubviews() {
		
		super.layoutSubviews()
		collectionView.frame = CGRect(x: 0, y: 1, width: contentView.frame.width, height: 120)
		pageControl.frame = CGRect(x: 0, y: frame.size.height - 17, width: frame.size.width, height: 12)
		pageControl.numberOfPages = Int(ceil(collectionView.contentSize.width / collectionView.frame.width))
	}
}

//MARK: -
//MARK: UICollectionViewDataSource
//MARK: -
extension AppCollectionCell {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return apps?.count ?? 0
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
		guard let apps = apps, let appCell = cell as? TSCAppScrollerItemViewCell else { return cell }
		
		let app = apps[indexPath.row]
		appCell.appIconView.image = app.appIcon
		appCell.nameLabel.text = app.appName
		appCell.priceLabel.text = app.appPrice
		
		return appCell
	}
}

//MARK: -
//MARK: UICollectionViewDelegateFlowLayout
//MARK: -
extension AppCollectionCell {
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 80, height: 120)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		guard let apps = apps, let identity = apps[indexPath.item].appIdentity, let launcher = identity.launcher, let launchURL = URL(string: launcher) else { return }
		
		if UIApplication.shared.canOpenURL(launchURL) {
			
			let alertViewController = UIAlertController(
				title: "Switching Apps".localised(with: "_COLLECTION_APP_CONFIRMATION_TITLE"),
				message: "You will now be taken to the app you have selected".localised(with: "_COLLECTION_APP_CONFIRMATION_MESSAGE"),
				preferredStyle: .alert)
			
			alertViewController.addAction(UIAlertAction(
				title: "Okay".localised(with: "_COLLECTION_APP_CONFIRMATION_OKAY"),
				style: .default,
				handler: { (action) in
					
					NotificationCenter.default.sendStatEventNotification(category: "Collect them all", action: "Open", label: nil, value: nil, object: self)
					UIApplication.shared.openURL(launchURL)
				}
			))
			
			alertViewController.addAction(UIAlertAction(
				title: "Cancel".localised(with: "_COLLECTION_APP_CONFIRMATION_CANCEL"),
				style: .default,
				handler: nil))
			
			parentViewController?.navigationController?.present(alertViewController, animated: true, completion: nil)
			
		} else if let itunesId = identity.iTunesId {
			
			NotificationCenter.default.sendStatEventNotification(category: "Collect them all", action: "App Store", label: nil, value: nil, object: self)
			UINavigationBar.appearance().tintColor = ThemeManager.shared.theme.titleTextColor
			
			let storeViewController = SKStoreProductViewController()
			storeViewController.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: itunesId], completionBlock: { (result, error) in
				
			})
			storeViewController.delegate = self
			parentViewController?.navigationController?.present(storeViewController, animated: true, completion: nil)
		}
	}
}

//MARK: -
//MARK: SKStoreProductViewControllerDelegate
//MARK: -
extension AppCollectionCell: SKStoreProductViewControllerDelegate {
	func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
		UINavigationBar.appearance().tintColor = .white
		viewController.dismissAnimated()
	}
}
