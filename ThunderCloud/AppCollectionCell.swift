//
//  AppCollectionCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import StoreKit
import ThunderTable

extension AppCollectionItem: CollectionCellDisplayable {
    
    public var itemImage: StormImage? {
        return appIcon
    }
    
    public var itemTitle: String? {
        return appName
    }
    
    public var enabled: Bool {
        guard let launchURL = app?.launchURL else {
            return false
        }
        return UIApplication.shared.canOpenURL(launchURL)
    }
    
    public var accessibilityLabel: String? {
        let params = [
            "APP_NAME": itemTitle ?? "Unknown".localised(with: "_APP_NAME_UNKNOWN")
        ]
        return enabled ?
            "{APP_NAME}. Installed.".localised(with: "_APP_COLLECTION_ITEM_INSTALLED", paramDictionary: params) :
            "{APP_NAME}. Not installed.".localised(with: "_APP_COLLECTION_ITEM_NOT_INSTALLED", paramDictionary: params)
    }
    
    public var accessibilityHint: String? {
        return nil
    }
    
    public var accessibilityTraits: UIAccessibilityTraits? {
        return [.button]
    }
}

/// A subclass of `CollectionCell` which displays the user a collection of apps.
/// Apps in this collection view are displayed as their app icon, with a price and name below them
open class AppCollectionCell: CollectionCell {
    
}

//MARK: -
//MARK: UICollectionViewDelegateFlowLayout
//MARK: -
public extension AppCollectionCell {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let apps = items as? [AppCollectionItem], let identity = apps[indexPath.item].app, let launchURL = identity.launchURL else { return }
        
        if UIApplication.shared.canOpenURL(launchURL) {
            
            let alertViewController = UIAlertController(
                title: "Switching Apps".localised(with: "_COLLECTION_APP_CONFIRMATION_TITLE"),
                message: "You will now be taken to the app you have selected".localised(with: "_COLLECTION_APP_CONFIRMATION_MESSAGE"),
                preferredStyle: .alert)
            
            alertViewController.addAction(UIAlertAction(
                title: "Okay".localised(with: "_COLLECTION_APP_CONFIRMATION_OKAY"),
                style: .default,
                handler: { (action) in
                    
                    NotificationCenter.default.sendAnalyticsHook(.appCollectionClick(identity))
                    UIApplication.shared.open(launchURL)
            }
            ))
            
            alertViewController.addAction(UIAlertAction(
                title: "Cancel".localised(with: "_COLLECTION_APP_CONFIRMATION_CANCEL"),
                style: .default,
                handler: nil))
            
            parentViewController?.navigationController?.present(alertViewController, animated: true, completion: nil)
            
        } else if let itunesId = identity.iTunesId {
            
            NotificationCenter.default.sendAnalyticsHook(.appCollectionClick(identity))
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
    
    public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        UINavigationBar.appearance().tintColor = .white
        viewController.dismissAnimated()
    }
}
