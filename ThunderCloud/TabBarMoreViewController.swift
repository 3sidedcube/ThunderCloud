//
//  TabBarMoreViewController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 05/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// A Re-implementation of the iOS standard "More" tab
@objc(TSCTabBarMoreViewController)
open class TabBarMoreViewController: TableViewController {

	public let viewControllers: [UIViewController]
	
	fileprivate var pushedNavigationController: UINavigationController?
	
	fileprivate var pushedViewController: UIViewController?
	
	/// Initialises a new instance with an array of `UIViewController`s
	///
	/// - Parameter viewControllers: The view controllers to display in the table
	public init(viewControllers: [UIViewController]) {
		
		self.viewControllers = viewControllers
		super.init(style: .grouped)
		
		tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 5)
		title = "More".localised(with: "_MORE_NAVIGATION_TITLE")
		navigationController?.delegate = self
	}
	
	required public init?(coder aDecoder: NSCoder) {
		viewControllers = []
		super.init(coder: aDecoder)
	}

	override open func viewDidLoad() {
		
		let rows = viewControllers.map { (viewController) -> Row in
			
			return TableRow(title: viewController.tabBarItem.title, subtitle: nil, image: viewController.tabBarItem.image, selectionHandler: { (row, wasSelected, indexPath, tableView) -> (Void) in
				
				tableView.deselectRow(at: indexPath, animated: true)
				self.navigationController?.delegate = self
				
				if indexPath.row < self.viewControllers.count {
					
					let viewController = self.viewControllers[indexPath.row]
					
					if let navController = viewController as? UINavigationController {
						
						self.pushedNavigationController = navController
						
						if let firstViewController = navController.viewControllers.first {
							
							self.pushedViewController = firstViewController
							self.navigationController?.pushViewController(firstViewController, animated: true)
							
						} else if let topViewController = navController.topViewController {
							
							self.pushedViewController = topViewController
							self.navigationController?.pushViewController(topViewController, animated: true)
						}
						
					} else {
						self.navigationController?.pushViewController(viewController, animated: true)
					}
				}
			})
		}
		
		let section = TableSection(rows: rows)
		data = [section]
	}
}

extension TabBarMoreViewController: UINavigationControllerDelegate {
	
	public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		
		if viewController == self, let pushedViewController = pushedViewController {
			pushedNavigationController?.viewControllers = [pushedViewController]
		}
	}
}
