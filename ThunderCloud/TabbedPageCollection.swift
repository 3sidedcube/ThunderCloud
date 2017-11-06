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
	
	internal var placeholders: [Placeholder] = []
	
	fileprivate var selectedTabIndex: Int? = 0
	
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
			
			placeholders.append(Placeholder(dictionary: tabBarItemDict))
			
			if let pageType = pageDictionary["type"] as? String, pageType == "TabbedPageCollection" {
				
				var pageTypeDictionary = pageDictionary
				// Not sure entirely why this happens
				pageTypeDictionary["type"] = "NavigationTabBarViewController"
				
				guard let tabViewControllerClass = StormObjectFactory.shared.class(for: NSStringFromClass(NavigationTabBarViewController.self)) as? StormObjectProtocol.Type else {
					print("[TabbedPageCollection] Please make sure your override for TSCNavigationTabBarViewController conforms to StormObjectProtocol")
					return
				}
				
				guard let navTabController = tabViewControllerClass.init(dictionary: pageTypeDictionary) as? UIViewController else {
					print("[TabbedPageCollection] Please make sure your override for TSCNavigationTabBarViewController is a subclass of UIViewController")
					return
				}
				
				let tabImage = tabBarImage(with: StormGenerator.image(fromJSON: tabBarItemDict["image"]))
				
				if let title = tabBarItemDict["title"] as? [AnyHashable : Any] {
					navTabController.title = StormLanguageController.shared.string(for: title)
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
				
				guard let viewController = StormGenerator.viewController(URL: pageURL) else {
					print("[TabbedPageCollection] Failed to allocate view controller at \(pageURL)")
					return
				}
				
				if let title = tabBarItemDict["title"] as? [AnyHashable : Any] {
					viewController.tabBarItem.title = StormLanguageController.shared.string(for: title)
				}
				
				let tabImage = tabBarImage(with: StormGenerator.image(fromJSON: tabBarItemDict["image"]))
				
				viewController.tabBarItem.image = tabImage?.withRenderingMode(.alwaysOriginal)
				viewController.tabBarItem.selectedImage = tabImage
				
				let navigationControllerClass = StormObjectFactory.shared.class(for: String(describing: UINavigationController.self)) as? UINavigationController.Type ?? UINavigationController.self
								
				let navController = viewController as? UINavigationController ?? navigationControllerClass.init(rootViewController: viewController)
				navController.pageIdentifier = pageSource
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
				guard let pageId = viewController.pageIdentifier else { return false }
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
	
	private var appearedBefore = false
	
	override open func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		guard !appearedBefore else { return }
		
		appearedBefore = true
		showPlaceholderViewController()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	// Implemented to avoid crash
	override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}

	//MARK: -
	//MARK: Helpers
	//MARK: -
	
	private func tabBarImage(with image: UIImage?) -> UIImage? {
		
		guard let image = image else { return nil }
		
		let rect = CGRect(x: 0, y: 0, width: 30, height: 30)
		UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
		image.draw(in: rect)
		let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return renderedImage
	}
	
	fileprivate func showPlaceholderViewController() {
		
		guard let selectedIndex = selectedTabIndex, UI_USER_INTERFACE_IDIOM() == .pad, selectedIndex < placeholders.count else { return }

		var splitViewController: SplitViewController?
		
		if let applicationWindow = UIApplication.shared.keyWindow {
			splitViewController = applicationWindow.rootViewController as? SplitViewController
		// This is gross.. because window is `UIWindow??` on app delegate for some reason...
		} else if let delegateWindow = UIApplication.shared.delegate?.window ?? nil {
			splitViewController = delegateWindow.rootViewController as? SplitViewController
		}
		
		guard let _splitViewController = splitViewController else {
			return
		}
		
		let placeholder = placeholders[selectedIndex]
		
		let placeholderVC = PlaceholderViewController(placeholder: placeholder)
		
		_splitViewController.detailViewController = UINavigationController(rootViewController: placeholderVC)
	}
	
	private func openNavigationLink(sender: UIBarButtonItem) {
		
		guard let viewControllers = viewControllers, sender.tag < viewControllers.count else {
			return
		}
		
		let viewController = viewControllers[sender.tag]
		if UI_USER_INTERFACE_IDIOM() == .pad, let splitViewController = UIApplication.shared.keyWindow?.rootViewController as? SplitViewController {
			splitViewController.detailViewController?.show(viewController, sender: self)
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
			return pageIdentifier
		}
		
		UserDefaults.standard.set(pageOrder, forKey: kTSCTabbedPageCollectionUsersPreferedOrderKey)
	}
}
