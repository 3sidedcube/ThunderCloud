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

	public required init() {
		
		let placeholderDetailVCClass = StormObjectFactory.shared.class(for: NSStringFromClass(DummyViewController.self)) as? UIViewController.Type ?? UIViewController.self
		
		let leftVC = placeholderDetailVCClass.init(nibName: nil, bundle: nil)
		primaryViewController = SplitViewController.navigationController(for: leftVC)
		
		let rightVC = placeholderDetailVCClass.init(nibName: nil, bundle: nil)
		detailViewController = SplitViewController.navigationController(for: rightVC)
		
        if #available(iOS 14.0, *) {
            super.init(style: .doubleColumn)
        } else {
            super.init(nibName: nil, bundle: nil)
        }
		
		view.backgroundColor = .black
	}
	
	public required init?(coder aDecoder: NSCoder) {
		
		let placeholderDetailVCClass = StormObjectFactory.shared.class(for: NSStringFromClass(DummyViewController.self)) as? UIViewController.Type ?? UIViewController.self
		
		let leftVC = placeholderDetailVCClass.init(nibName: nil, bundle: nil)
		primaryViewController = SplitViewController.navigationController(for: leftVC)
		
		super.init(coder: aDecoder)
	}
	
	/// Sets the view controller for the detail view of the `UISplitViewController`
	///
	/// If the navController parameter is the currently displayed `UIViewController` in the master view or is contained in a `TSCAccordionTabBarViewController` the view will just appear in the detail view, otherwise it will be pushed by the detail view's `UINavigationController`
	///
	/// - Parameters:
	///   - viewController: The `UIViewController` to be set or pushed in the detail view
	///   - navigationController: The `UINavigationController` that should show the view
	public func setRightViewController(_ viewController: UIViewController, from navigationController: UINavigationController?) {
		
		if detailViewController is DummyViewController
			|| navigationController?.tabBarController == primaryViewController
			|| navigationController == primaryViewController
			|| navigationController?.parent is AccordionTabBarViewController
			|| viewController is PlaceholderViewController {
			
			detailViewController = SplitViewController.navigationController(for: viewController)
			
			// Don't push if it's a navigation controller, because that crashes
		} else if let navigationController = detailViewController as? UINavigationController, viewController as? UINavigationController == nil {
			
			navigationController.pushViewController(viewController, animated: true)
			
		} else {
			
			detailViewController = SplitViewController.navigationController(for: viewController)
		}
	}
	
	//MARK: -
	//MARK: - Helpers
	
	override open var viewControllers: [UIViewController] {
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
