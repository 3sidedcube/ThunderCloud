//
//  SplitViewController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 11/10/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// Subclass of `UISplitViewController` that gives easier support for pushing and presenting view controllers, whether it be as a full-screen modal, in the master view or detail view
open class SplitViewController: UISplitViewController {
	
	/// The currently displayed `UIViewController` in the master view of the split
	public var primaryViewController: UIViewController
	
	/// The currently displayed `UIViewController` in the detail view of the split
	public var detailViewController: UIViewController? {
		didSet {
			if let detailViewController = detailViewController {
				super.viewControllers = [primaryViewController, detailViewController]
			}
		}
	}

	public init() {
		
		let placeholderDetailVCClass = StormObjectFactory.shared.class(for: NSStringFromClass(TSCDummyViewController.self)) as? UIViewController.Type ?? UIViewController.self
		
		let leftVC = placeholderDetailVCClass.init(nibName: nil, bundle: nil)
		primaryViewController = SplitViewController.navigationController(for: leftVC)
		
		let rightVC = placeholderDetailVCClass.init(nibName: nil, bundle: nil)
		detailViewController = SplitViewController.navigationController(for: rightVC)
		
		super.init(nibName: nil, bundle: nil)
		
		view.backgroundColor = .black
	}
	
	public required init?(coder aDecoder: NSCoder) {
		
		let placeholderDetailVCClass = StormObjectFactory.shared.class(for: NSStringFromClass(TSCDummyViewController.self)) as? UIViewController.Type ?? UIViewController.self
		
		let leftVC = placeholderDetailVCClass.init(nibName: nil, bundle: nil)
		primaryViewController = SplitViewController.navigationController(for: leftVC)
		
		super.init(coder: aDecoder)
	}
	
	//MARK: -
	//MARK: - Navigation methods
	
	/// Sets the view controller for the master view of the `UISplitViewController`
	///
	/// This will automaticall wrap the view controller in a `UINavigationController` if it isn't an instance or contained in one
	///
	/// - Parameter to: The view controller to show in the master view
	public func setLeftViewController(_ viewController: UIViewController) {
		
		primaryViewController = SplitViewController.navigationController(for: viewController)
		
		var viewControllers = [primaryViewController]
		if let detailViewController = detailViewController {
			viewControllers.append(detailViewController)
		}
		super.viewControllers = viewControllers
	}
	
	private var modalPopoverViewController: UIViewController?
	
	/// Sets the view controller for the detail view of the `UISplitViewController`
	///
	/// If the navController parameter is the currently displayed `UIViewController` in the master view or is contained in a `TSCAccordionTabBarViewController` the view will just appear in the detail view, otherwise it will be pushed by the detail view's `UINavigationController`
	///
	/// - Parameters:
	///   - viewController: The `UIViewController` to be set or pushed in the detail view
	///   - navigationController: The `UINavigationController` that should show the view
	public func setRightViewController(_ viewController: UIViewController, from navigationController: UINavigationController?) {
		
		if detailViewController is TSCDummyViewController
			|| navigationController?.tabBarController == primaryViewController
			|| navigationController == primaryViewController
			|| navigationController?.parent is TSCAccordionTabBarViewController
			|| viewController is TSCPlaceholderViewController {
			
			detailViewController = SplitViewController.navigationController(for: viewController)
			
		} else if let navigationController = detailViewController as? UINavigationController {
			
			navigationController.pushViewController(viewController, animated: true)
			
		} else {
			
			detailViewController = SplitViewController.navigationController(for: viewController)
		}
		
		if let _ = navigationController?.parent as? TSCAccordionTabBarViewController, let modalPopoverViewController = modalPopoverViewController {
			modalPopoverViewController.dismissAnimated()
		}
	}
	
	//MARK: -
	//MARK: - Helpers
	
	open override var viewControllers: [UIViewController] {
		set {
			if let leftViewController = newValue.first {
				primaryViewController = leftViewController
			}
			if newValue.count > 1 {
				setRightViewController(newValue[1], from: nil)
			}
			if let detailViewController = detailViewController {
				super.viewControllers = [primaryViewController, detailViewController]
			}
		}
		get {
			return super.viewControllers
		}
	}
	
	private static func navigationController(for viewController: UIViewController) -> UIViewController {
		
		if viewController is UINavigationController || viewController is TabbedPageCollection {
			return viewController
		} else {
			return UINavigationController(rootViewController: viewController)
		}
	}
}
