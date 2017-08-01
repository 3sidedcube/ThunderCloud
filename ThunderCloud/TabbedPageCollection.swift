//
//  TabbedPageCollection.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 13/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

let kTSCTabbedPageCollectionUsersPreferedOrderKey = "TSCTabbedPageCollectionUsersPreferedOrder"

/// Storm representation of `UITabBarController`
///
/// Allows initialisation of a `UITabBarController` using a dictionary taken from the app bundle
/// - Implements a custom "more" page if it is provided with more than 5 view controllers
/// - Stores tab arrangement to UserDefaults
@objc(TSCTabbedPageCollection)
open class TabbedPageCollection: UITabBarController, StormObjectProtocol {
	
	private var placeholders: [TSCPlaceholder] = []
	
	fileprivate var selectedTabIndex: Int?
	
	/// Initializes a `TabbedPageCollection` using a dictionary representation
	///
	/// - Parameter dictionary: The dictionary representation of a tabbed page collection
	required public init(dictionary: [AnyHashable : Any]) {
		
		super.init(viewControllers: [])
		delegate = self
		
		// Load root storm pages
		guard let pageDictionaries = dictionary["pages"] as? [[AnyHashable : Any]] else {
			return
		}
		
		var finalViewControllers: [UIViewController] = []
		
		pageDictionaries.forEach { (pageDictionary) in
			
			guard let tabBarItemDict = pageDictionary["tabBarItem"] as? [AnyHashable : Any] else { return }
			
			placeholders.append(TSCPlaceholder(dictionary: tabBarItemDict))
			
			if let pageType = pageDictionary["type"] as? String, pageType == "TabbedPageCollection" {
				
				var pageTypeDictionary = pageDictionary
				// Not sure entirely why this happens
				pageTypeDictionary["type"] = "NavigationTabBarViewController"
				
				guard let tabViewControllerClass = StormObjectFactory.shared.class(for: NSStringFromClass(TSCNavigationTabBarViewController.self)) as? StormObjectProtocol.Type else {
					print("[TabbedPageCollection] Please make sure your override for TSCNavigationTabBarViewController conforms to StormObjectProtocol")
					return
				}
				
				guard let navTabController = tabViewControllerClass.init(dictionary: pageTypeDictionary) as? UIViewController else {
					print("[TabbedPageCollection] Please make sure your override for TSCNavigationTabBarViewController is a subclass of UIViewController")
					return
				}
				
				var tabImage: UIImage?
				if let tabImageObject = tabBarItemDict["image"] as? NSObject {
					tabImage = TSCImage.image(withJSONObject: tabImageObject)
				}
				tabImage = tabBarImage(with: tabImage)
				
				if let title = tabBarItemDict["title"] as? [AnyHashable : Any] {
					navTabController.title = TSCStormLanguageController.shared().string(for: title)
				}
				
				navTabController.tabBarItem.image = tabImage?.withRenderingMode(.alwaysOriginal)
				navTabController.tabBarItem.selectedImage = tabImage
				
				let navController = navTabController as? UINavigationController ?? UINavigationController(rootViewController: navTabController)
				finalViewControllers.append(navController)
				
			} else {
				
				guard let pageSource = pageDictionary["src"] as? String, let pageURL = URL(string: pageSource) else {
					print("[TabbedPageCollection] Failed to allocate view controller as no (or invalid) src present")
					return
				}
				
				guard let viewController = TSCStormViewController.viewController(with: pageURL) as? UIViewController else {
					print("[TabbedPageCollection] Failed to allocate view controller at \(pageURL)")
					return
				}
				
				if let title = tabBarItemDict["title"] as? [AnyHashable : Any] {
					viewController.tabBarItem.title = TSCStormLanguageController.shared().string(for: title)
				}
				
				var tabImage: UIImage?
				if let tabImageObject = tabBarItemDict["image"] as? NSObject {
					tabImage = TSCImage.image(withJSONObject: tabImageObject)
				}
				tabImage = tabBarImage(with: tabImage)
				
				viewController.tabBarItem.image = tabImage?.withRenderingMode(.alwaysOriginal)
				viewController.tabBarItem.selectedImage = tabImage
				
				let navController = viewController as? UINavigationController ?? UINavigationController(rootViewController: viewController)
				navController.setPageIdentifier(pageSource)
				finalViewControllers.append(navController)
			}
		}
		
		// Custom more page if more than 5 view controllers
		if finalViewControllers.count > 5 {
			
			// Get the remaining view controllers
			let moreViewControllers = Array(finalViewControllers[4..<finalViewControllers.count])
			// Get the first 4 view controllers
			finalViewControllers = Array(finalViewControllers[0..<4])
			
			let moreViewController = TabBarMoreViewController(viewControllers: moreViewControllers)
			let moreNavController = UINavigationController(rootViewController: moreViewController)
			finalViewControllers.append(moreNavController)
		}
		
		// Page ordering
		
		guard let perferredOrder = UserDefaults.standard.object(forKey: kTSCTabbedPageCollectionUsersPreferedOrderKey) as? [String] else {
			viewControllers = finalViewControllers
			return
		}
		
		var orderedViewControllers = perferredOrder.enumerated().flatMap { (index, pageIdentifier) -> UIViewController? in
			
			// Find the view controller in finalViewControllers with the correct identifier
			let matchingViewController = finalViewControllers.first(where: { (viewController) -> Bool in
				guard let pageId = viewController.pageIdenitifer() as? String else { return false }
				return pageId == pageIdentifier
			})
			
			// If we found a match, then remove it from the initial view controllers otherwise we add it in again later and get duplicates
			if matchingViewController != nil {
				finalViewControllers.remove(at: index)
			}
			
			return matchingViewController
		}
		
		// As new pages could be added in that don't have a prefered order. To prevent these from being missed out, just add them on the end
		orderedViewControllers.append(contentsOf: finalViewControllers)
		viewControllers = orderedViewControllers
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	// Implemented to avoid crash
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	//MARK: -
	//MARK: Helpers
	//MARK: -
	
	private func tabBarImage(with image: UIImage?) -> UIImage? {
		
		guard let _image = image else { return nil }
		
		let rect = CGRect(x: 0, y: 0, width: 30, height: 30)
		UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
		_image.draw(in: rect)
		let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return renderedImage
	}
	
	fileprivate func showPlaceholderViewController() {
		
		guard let selectedIndex = selectedTabIndex, UI_USER_INTERFACE_IDIOM() == .pad, selectedIndex < placeholders.count else { return }
		
		let retainKey = "\(selectedTabIndex)"
		
		if TSCSplitViewController.shared().retainKeyAlreadyStored(retainKey) {
			TSCSplitViewController.shared().setRightViewControllerUsingRetainKey(retainKey)
		} else {
			let placeholder = placeholders[selectedIndex]
			
			let placeholderVC = TSCPlaceholderViewController()
			placeholderVC.title = placeholder.title
			placeholderVC.placeholderDescription = placeholder.placeholderDescription
			placeholderVC.image = placeholder.image
			
			TSCSplitViewController.shared().setRight(placeholderVC, from: navigationController, usingRetainKey: retainKey)
		}
	}
	
	private func openNavigationLink(sender: UIBarButtonItem) {
		
		guard let _viewControllers = viewControllers, sender.tag < _viewControllers.count else {
			return
		}
		
		let viewController = _viewControllers[sender.tag]
		if UI_USER_INTERFACE_IDIOM() == .pad {
			TSCSplitViewController.shared().setRight(viewController, from: navigationController)
		} else if let navigationController = selectedViewController as? UINavigationController {
			navigationController.pushViewController(viewController, animated: true)
		} else {
			selectedViewController?.navigationController?.pushViewController(viewController, animated: true)
		}
	}
}

extension TabbedPageCollection: UITabBarControllerDelegate {
	
	public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
		
		selectedTabIndex = viewControllers?.index(of: viewController)
		showPlaceholderViewController()
	}
	
	public func tabBarController(_ tabBarController: UITabBarController, didEndCustomizing viewControllers: [UIViewController], changed: Bool) {
		
		let pageOrder = viewControllers.flatMap { (viewController) -> String? in
			return viewController.pageIdenitifer() as? String
		}
		
		UserDefaults.standard.set(pageOrder, forKey: kTSCTabbedPageCollectionUsersPreferedOrderKey)
	}
}
