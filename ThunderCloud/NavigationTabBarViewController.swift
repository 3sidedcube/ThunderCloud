//
//  NavigationTabBarViewController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 30/10/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// A subclass of UIViewController which displays a `UISegmentedControl` to switch between view controllers within a `UINavigationController`
///
/// This class also listens to changes on the navigation items of it's children so will change left and right items as you tab between children
///
/// If you want to have shared navigation items between all of the children, please make sure when subclassing this class to set any shared navigationItems within your `init(dictionary:)` function.
open class NavigationTabBarViewController: UIViewController, StormObjectProtocol {
	
	//MARK: - Public API -
	
	/// Defines the placement of the `UISegmentedControl` which controls the tabs
	///
	/// - insideNavigationBar: The segmented control will be shown within the `UINavigationController`'s navigation bar
	/// - belowNavigationBar: The segmented control will be shown below the `UINavigationController`'s navigation bar
	public enum TabBarPlacement {
		case insideNavigationBar
		case belowNavigationBar
	}
	
	/// The current tab placement for the tab bar view controller
	///
	/// Setting this will not update the placement until re-setting the `viewController` property
	///
	/// - Warning: Setting this may lead to un-expected behaviour or even crashing and has not been tested thoroughly
	open var tabPlacement: TabBarPlacement = .insideNavigationBar
	
	/// The segmented control used to switch between tabs in the navigation controller
	open var segmentedControl = UISegmentedControl()
	
	/// The containing view for the segmented control
	open var segmentedView = UIView()
	
	/// The array of view controllers which the user can tab between
	///
	/// - Remark: Setting of this manually isn't tested, however it should behave fine and upda
	open var viewControllers: [UIViewController]? {
		didSet {
			redrawSegmentedControl()
		}
	}
	
	/// The currently selected `UIViewController`
	///
	/// Setting this manually will update the currently displayed view controller and the selection state of the `UISegmentedControl`
	///
	/// - Warning: Will not do anything if set to a view controller not present in `viewControllers`
	open var selectedViewController: UIViewController? {
		set {
			
			guard let newValue = newValue else {
				print("[NavigationTabBarViewController] Setting selectedViewController to nil is not supported")
				return
			}
			
			guard let viewControllers = viewControllers, let selectedIndex = viewControllers.firstIndex(of: newValue) else {
				print("[NavigationTabBarViewController] Failed to set selected view controller because it is not in the allowed viewControllers array")
				return
			}
			
			// This will handle removing the old and adding the new view controller to the hierarchy!
			selectedTabIndex = selectedIndex
		}
		get {
			return children.first
		}
	}
	
	/// The index of the currently selected `UIViewController`
	///
	/// Setting this will select the view controller at that index and update the `UISegmentedControl` to reflect the change
	open var selectedTabIndex: Int = -1 { // Defaults to -1 so initial layout rung because of first guard!
		didSet {
			
			// Don't do anything if the selected tab hasn't changed!
			guard let viewControllers = viewControllers, oldValue != selectedTabIndex else {
				return
			}
			
			// Make sure index not out of bounds
			guard selectedTabIndex < viewControllers.count else {
				print("[NavigationTabBarViewController] Failed to set selected view controller to view controller out of bounds!")
				return
			}
			
			// Set the selected segment index
			segmentedControl.selectedSegmentIndex = selectedTabIndex
			
			// Prepare currently selected view controller for removal
			selectedViewController?.willMove(toParent: nil)
			selectedViewController?.removeFromParent()
			selectedViewController?.view.removeFromSuperview()
			selectedViewController?.didMove(toParent: nil)
			
			// Remove navigation item KVO
			removeNavigationItemObservers()
			
			let newViewController = viewControllers[selectedTabIndex]
			
			newViewController.willMove(toParent: self)
			
			// This is here because it was in the Objective-C version... Should investigate it's removal
			if UI_USER_INTERFACE_IDIOM() == .pad {
				newViewController.viewWillAppear(true)
			}
			
			addChild(newViewController)
			
			// Make sure if the user has set the button items on the parent "Container" navigation item we don't override them with the child view controllers items.
			if !definesOwnRightNavigationItems {
				
				navigationItem.rightBarButtonItems = newViewController.navigationItem.rightBarButtonItems
				
				// If the new selected view controller has right bar button items
				if let newRightBarButtonItems = newViewController.navigationItem.rightBarButtonItems, !newRightBarButtonItems.isEmpty {
					
					observingRightNavigationItems = true
					newViewController.navigationItem.addObserver(self, forKeyPath: "rightBarButtonItems", options: [], context: nil)
					newViewController.navigationItem.addObserver(self, forKeyPath: "rightBarButtonItem", options: [], context: nil)
					
				} else {
					observingRightNavigationItems = false
				}
			}
			
			if !definesOwnLeftNavigationItems {
				
				navigationItem.leftBarButtonItems = newViewController.navigationItem.leftBarButtonItems
				
				// If the new selected view controller has left bar button items
				if let newLeftBarButtonItems = newViewController.navigationItem.leftBarButtonItems, !newLeftBarButtonItems.isEmpty {
					
					observingLeftNavigationItems = true
					newViewController.navigationItem.addObserver(self, forKeyPath: "leftBarButtonItems", options: [], context: nil)
					newViewController.navigationItem.addObserver(self, forKeyPath: "leftBarButtonItem", options: [], context: nil)
					
				} else {
					observingLeftNavigationItems = false
				}
			}
			
			view.addSubview(newViewController.view)
			viewWillLayoutSubviews()
			newViewController.didMove(toParent: self)
			
			// This is here because it was in the Objective-C version... Should investigate it's removal
			if UI_USER_INTERFACE_IDIOM() == .pad {
				newViewController.viewDidAppear(true)
			}
			
			if tabPlacement == .belowNavigationBar {
				
				segmentedView.removeFromSuperview()
				view.addSubview(segmentedView)
				
				segmentedView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 40)
				segmentedControl.frame = CGRect(x: 10, y: 5, width: view.bounds.width - 20, height: 30)
				segmentedView.addSubview(segmentedControl)
			}
			
			if let shouldUpdateTitle = Bundle.main.object(forInfoDictionaryKey: "TSCNavigationTabBarSelectionShouldUpdateTitle") as? Bool, shouldUpdateTitle {
				title = newViewController.title
			}
			
			navigationController?.view.setNeedsLayout()
		}
	}
	
	/// Creates a new instance with a dictionary representation from Storm
	///
	/// - Parameter dictionary: The dictionary to initialise and setup with
	public required init(dictionary: [AnyHashable : Any]) {
		
		super.init(nibName: nil, bundle: nil)
		
		guard let source = dictionary["src"] as? String, let pageURL = ContentController.shared.url(forCacheURL: URL(string: source)) else {
			return
		}
		
		guard let pageData = try? Data(contentsOf: pageURL), let pageDictionary = (try? JSONSerialization.jsonObject(with: pageData, options: [])) as? [AnyHashable : Any] else {
			return
		}
		
		guard let pageDictionaries = pageDictionary["pages"] as? [[AnyHashable : Any]] else {
			return
		}
		
		viewControllers = pageDictionaries.compactMap { (pageDictionary) -> UIViewController? in
			
			guard let source = pageDictionary["src"] as? String, let sourceURL = URL(string: source) else {
				return nil
			}
			
			return StormGenerator.viewController(URL: sourceURL)
		}
	}
	
	/// Creates a new instance with an array of `UIViewController`s to display
	///
	/// - Parameter viewControllers: The view controllers to display
	/// - Parameter tabBarPlacement: The placement of the segmented control
	public required init(viewControllers: [UIViewController], tabBarPlacement: TabBarPlacement) {
		
		super.init(nibName: nil, bundle: nil)
		
		self.viewControllers = viewControllers
		self.tabPlacement = tabBarPlacement
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	//MARK: - View Lifecycle -
	
	deinit {
		
		removeNavigationItemObservers()
	}
	
	override open func viewDidLoad() {
		
        super.viewDidLoad()

		// If navigation items are nil, then doesn't define it's own
        definesOwnLeftNavigationItems = navigationItem.leftBarButtonItems?.isEmpty ?? false
		definesOwnRightNavigationItems = navigationItem.rightBarButtonItems?.isEmpty ?? false
		
		redrawSegmentedControl()
		
		// This is important for initial layout
		selectedTabIndex = 0
    }
	
	open override func viewWillLayoutSubviews() {
		
		super.viewWillLayoutSubviews()
		
		switch tabPlacement {
		case .insideNavigationBar:
			selectedViewController?.view.frame = view.bounds
			break
		case .belowNavigationBar:
			
			var viewFrame = view.bounds
			viewFrame.origin.y += 40
			viewFrame.size.height -= 40
			
			selectedViewController?.view.frame = viewFrame
			
			navigationController?.navigationBar.shadowImage = UIImage()
			
			break
		}
	}
	
	//MARK: - Private API -
	
	private var observingRightNavigationItems = false
	
	private var observingLeftNavigationItems = false
	
	private var definesOwnLeftNavigationItems = false
	
	private var definesOwnRightNavigationItems = false
	
	@objc private func handleSelectedIndex(sender: UISegmentedControl) {
		selectedTabIndex = sender.selectedSegmentIndex
	}
	
	private func removeNavigationItemObservers() {
		
		if observingRightNavigationItems {
			
			selectedViewController?.navigationItem.removeObserver(self, forKeyPath: "rightBarButtonItems")
			selectedViewController?.navigationItem.removeObserver(self, forKeyPath: "rightBarButtonItem")
		}
		
		if observingLeftNavigationItems {
			
			selectedViewController?.navigationItem.removeObserver(self, forKeyPath: "leftBarButtonItems")
			selectedViewController?.navigationItem.removeObserver(self, forKeyPath: "leftBarButtonItem")
		}
	}
	
	private func redrawSegmentedControl() {
		
		navigationItem.titleView = nil
		segmentedControl.removeFromSuperview()
		segmentedControl.removeAllSegments()
		
		segmentedControl = UISegmentedControl(items: [])
		segmentedControl.frame = CGRect(x: 0, y: 0, width: (UIApplication.shared.keyWindow?.bounds.width ?? UIScreen.main.bounds.width) - 120, height: 25)
		
		viewControllers?.forEach({ (viewController) in
			
			segmentedControl.insertSegment(withTitle: viewController.title ?? "No title", at: segmentedControl.numberOfSegments, animated: false)
		})
		
		segmentedControl.addTarget(self, action: #selector(handleSelectedIndex(sender:)), for: .valueChanged)
		
		switch tabPlacement {
		case .insideNavigationBar:
			navigationItem.titleView = segmentedControl
			break
		case .belowNavigationBar:
			
			segmentedControl.tintColor = .white
			segmentedControl.backgroundColor = ThemeManager.shared.theme.mainColor
			
			break
		}
	}
	
	open override var preferredStatusBarStyle: UIStatusBarStyle {
		return viewControllers?.first?.preferredStatusBarStyle ?? .default
	}
	
	//MARK: KVO -
	
	open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		
		guard let keyPath = keyPath else { return }
		
		switch keyPath {
		case "leftBarButtonItem":
			navigationItem.leftBarButtonItem = selectedViewController?.navigationItem.leftBarButtonItem
			break
		case "rightBarButtonItem":
			navigationItem.rightBarButtonItem = selectedViewController?.navigationItem.rightBarButtonItem
			break
		case "leftBarButtonItems":
			navigationItem.leftBarButtonItems = selectedViewController?.navigationItem.leftBarButtonItems
			break
		case "rightBarButtonItems":
			navigationItem.rightBarButtonItems = selectedViewController?.navigationItem.rightBarButtonItems
			break
		default:
			break
		}
	}
    
    open override var toolbarItems: [UIBarButtonItem]? {
        get {
            // Return the selected view controller's toolbar items as we're just a dummy container for
            // real content/view controllers
            return selectedViewController?.toolbarItems
        }
        set { }
    }
}
