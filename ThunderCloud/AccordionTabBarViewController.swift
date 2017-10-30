//
//  AccordionTabBarViewController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 27/10/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

class ScrollDisabledTableView: UITableView {
	
	override func scrollRectToVisible(_ rect: CGRect, animated: Bool) {
		
	}
	
	override var contentOffset: CGPoint {
		get {
			return super.contentOffset
		}
		set {
			
		}
	}
}

public class AccordionTabBarItem: Row {
	
	public var title: String? {
		get {
			return viewController.tabBarItem.title
		}
		set {
			
		}
	}
	
	public var image: UIImage? {
		get {
			return viewController.tabBarItem.image?.withRenderingMode(.alwaysTemplate)
		}
		set {
			
		}
	}
	
	private var searchBar: UISearchBar? {
		
		if #available(iOS 11, *) {
			return viewController.navigationItem.searchController?.searchBar
		}
		
		return nil
	}
	
	private var titleView: UIView? {
		return viewController.navigationItem.titleView
	}
	
	let viewController: UIViewController
	
	public init(viewController: UIViewController) {
		
		self.viewController = viewController
	}
	
	public var remainingHeight: CGFloat = 0
	
	private var viewControllerHeight: CGFloat {
		return searchBar != nil ? remainingHeight - 56 : (titleView != nil ? remainingHeight - 44 : remainingHeight)
	}
	
	public var expanded: Bool = false {
		didSet {
			if expanded {
				viewController.view.frame = CGRect(x: 0, y: 0, width: 0, height: viewControllerHeight)
			} else {
				viewController.view.frame = .zero
			}
		}
	}
	
	public var isFirstItem: Bool = false
	
	public func height(constrainedTo size: CGSize, in tableView: UITableView) -> CGFloat? {
		let height = expanded ? remainingHeight + 44 : 44
		return isFirstItem ? height + 20 : height
	}
	
	public var cellClass: AnyClass? {
		return AccordionTabBarItemTableViewCell.self
	}
	
	public func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		
		guard let accordionCell = cell as? AccordionTabBarItemTableViewCell else { return }
		
		viewController.view.frame.size.width = accordionCell.viewControllerView.frame.width
		accordionCell.cellImageView.isHidden = image == nil
		
		var backgroundColor = ThemeManager.shared.theme.secondaryColor
		let contrastingColor = expanded || isFirstItem ? ThemeManager.shared.theme.primaryLabelColor.contrasting() : ThemeManager.shared.theme.secondaryColor.contrasting()
		
		if expanded {
			backgroundColor = isFirstItem ? .clear : ThemeManager.shared.theme.mainColor
		} else if isFirstItem {
			backgroundColor = .clear
		}
		
		accordionCell.backgroundColor = backgroundColor
		accordionCell.contentView.backgroundColor = backgroundColor
		accordionCell.cellTextLabel.textColor = contrastingColor
		accordionCell.cellImageView.tintColor = contrastingColor
		
		accordionCell.topConstraint.constant = isFirstItem ? 28 : 8
		
		accordionCell.viewControllerView.subviews.forEach { (view) in
			view.removeFromSuperview()
		}
		accordionCell.customTitleView.subviews.forEach { (view) in
			view.removeFromSuperview()
		}
		
		accordionCell.customTitleHeightConstraint.constant = searchBar != nil ? 44 + 12 : (titleView != nil ? 44 : 0)
		
		viewController.view.frame = accordionCell.viewControllerView.bounds
		
		guard expanded else { return }
		
		accordionCell.viewControllerView.addSubview(viewController.view)
		
		guard let titleView = titleView ?? searchBar else { return }
		
		titleView.translatesAutoresizingMaskIntoConstraints = false
		accordionCell.customTitleView.addSubview(titleView)
		
		let viewsDict = ["view": titleView]
		accordionCell.customTitleView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: [], metrics: nil, views: viewsDict))
		accordionCell.customTitleView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: [], metrics: nil, views: viewsDict))
	}
	
	public var accessoryType: UITableViewCellAccessoryType? {
		get {
			return UITableViewCellAccessoryType.none
		}
		set {}
	}
}

/// A subvlass of `UIViewController` which replaces `UITabBarController`.
/// Displays the tabs which would be visible in a `UITabBarController` in a table view style, with each item being a cell
/// When a cell is selected the `UIViewController` for the selected tab is expanded underneath the item's cell and all other "tabs" are minimised. By default the top item is automatically expanded.
/// This is best used on iPad for displaying tabbed content in the master portion of a `UISplitViewController`
open class AccordionTabBarViewController: TableViewController, StormObjectProtocol {
	
	/// An array of tab bar items that are being shown
	open var tabBarItems: [AccordionTabBarItem] = []
	
	/// An array of `UIViewController`s each 'attached' to an individual `AccordionTabBarItem`
	open var viewControllers: [UIViewController] = []
	
	/// The currently displayed (Expanded) `UIViewController`
	open var selectedViewController: UIViewController? {
		guard let selectedTabIndex = selectedTabIndex, selectedTabIndex < viewControllers.count else {
			return nil
		}
		return viewControllers[selectedTabIndex]
	}
	
	/// The currently selected tab index
	open var selectedTabIndex: Int? = 0
	
	private var placeholders: [TSCPlaceholder] = []
	
	private var viewControllersShouldDisplayNavigationBar: [Bool] = []
	
	open override func loadView() {
		
		tableView = ScrollDisabledTableView(frame: UIScreen.main.bounds, style: .grouped)
		tableView.delegate = self
		tableView.dataSource = self
		view = tableView
	}
	
	//MARK: -
	//MARK: - View Lifecycle
	
	public required init(dictionary: [AnyHashable : Any]) {
		
		super.init(style: .grouped)
		
		automaticallyAdjustsScrollViewInsets = false
		edgesForExtendedLayout = .all
		extendedLayoutIncludesOpaqueBars = true
		navigationController?.automaticallyAdjustsScrollViewInsets = false
		
		// Load root storm pages
		guard let pageDictionaries = dictionary["pages"] as? [[AnyHashable : Any]] else {
			return
		}
		
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
				
				if let tabImageObject = tabBarItemDict["image"] as? NSObject {
					navTabController.tabBarItem.image = TSCImage.image(withJSONObject: tabImageObject)
				}
				
				if let title = tabBarItemDict["title"] as? [AnyHashable : Any] {
					navTabController.title = StormLanguageController.shared.string(for: title)
				}

				viewControllers.append(navTabController)
				viewControllersShouldDisplayNavigationBar.append(false)
				
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
				
				if let tabImageObject = tabBarItemDict["image"] as? NSObject {
					viewController.tabBarItem.image = TSCImage.image(withJSONObject: tabImageObject)
				}
				
				viewControllers.append(viewController)
				viewControllersShouldDisplayNavigationBar.append(false)
			}
		}
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override open func viewDidLoad() {
		
		super.viewDidLoad()
		
		tableView.separatorStyle = .singleLine
		tableView.separatorColor = UIColor.white.withAlphaComponent(0.4)
		tableView.showsVerticalScrollIndicator = false
		
		tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0.01, height: 0.01))
		tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0.01, height: 0.01))
		tableView.bounces = false
		tableView.isScrollEnabled = false
		view.backgroundColor = .clear
		navigationController?.view.backgroundColor = .groupTableViewBackground
		
		tableView.contentInset = .zero
		
		tabBarItems = viewControllers.map({ (viewController) -> AccordionTabBarItem in
			return AccordionTabBarItem(viewController: viewController)
		})
	
		showPlaceholderViewController()
		redraw()
		
		guard let firstViewController = viewControllers.first else { return }
		
		firstViewController.willMove(toParentViewController: self)
		addChildViewController(firstViewController)
		firstViewController.didMove(toParentViewController: self)
	}
	
	private var hasAppearedBefore = false
	
	override open func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		// Don't want to show placeholder here otherwise views are stripped off-screen
		// when the user shows/hides the accordion popover
		if !hasAppearedBefore {
			showPlaceholderViewController()
		}
		
		hasAppearedBefore = true
		
		navigationController?.setNavigationBarHidden(false, animated: false)
		
		// Needs to be done here for portait view errors
		extendedLayoutIncludesOpaqueBars = true
		
		guard let navigationController = navigationController else { return }
		navigationController.view.sendSubview(toBack: navigationController.navigationBar)
	}
	
	open override func viewDidAppear(_ animated: Bool) {
		
		super.viewDidAppear(animated)
		
		guard let navigationController = navigationController else { return }
		
		navigationController.view.sendSubview(toBack: navigationController.navigationBar)
	}
	
	open override func viewDidLayoutSubviews() {
		
		super.viewDidLayoutSubviews()
		
		guard let navigationController = navigationController else { return }
		navigationController.view.sendSubview(toBack: navigationController.navigationBar)
		
		let remainingHeight = view.frame.height - (CGFloat(tabBarItems.count) * 44.0) - tableView.contentInset.top - 20
		
		// Make sure to resize when rotate and remaining height changes!
		if remainingHeight != tabBarItems.first?.remainingHeight {
			
			tabBarItems.enumerated().forEach { (index, tabItem) in
				tabItem.remainingHeight = remainingHeight
			}
			
			if let selectedIndex = selectedTabIndex, tabBarItems[selectedIndex].expanded {
				tableView.reloadRows(at: [IndexPath(row: selectedIndex, section: 0)], with: .automatic)
			}
		}
		
		if tableView.contentInset == .zero {
			
			tableView.clipsToBounds = false
			tableView.contentInset = .zero
		}
	}
	
	//MARK: -
	//MARK: - Drawing
	
	private func redraw() {
		
		let remainingHeight = view.frame.height - (CGFloat(tabBarItems.count) * 44.0) - tableView.contentInset.top - 20
		
		tabBarItems.enumerated().forEach { (index, tabItem) in
			tabItem.expanded = index == selectedTabIndex
			tabItem.remainingHeight = remainingHeight
			tabItem.isFirstItem = index == 0
		}

		let tabSection = TableSection(rows: tabBarItems, header: nil, footer: nil) { (row, selected, indexPath, tableView) -> (Void) in
			
			guard let tabItem = row as? AccordionTabBarItem else { return }
			
			// Set selected tab and then show placeholder view controller
			self.selectedTabIndex = indexPath.row
			self.showPlaceholderViewController()
			
			// Index paths to redraw
			var redrawIndexPaths: [IndexPath] = [indexPath]
			
			var previousViewController: UIViewController?
			
			// Order of this line and line where we toggle the selected items expanded is important as we want to close the selected
			// row before toggling the one which was just selected!
			if let selectedIndex = self.tabBarItems.enumerated().first(where: { $0.1.expanded }), indexPath.row != selectedIndex.offset {
				
				previousViewController = selectedIndex.element.viewController
				redrawIndexPaths.append(IndexPath(row: selectedIndex.offset, section: 0))
				selectedIndex.element.expanded = false
			}
			
			// If was previously expanded it's view controller will be hidden
			if tabItem.expanded {
				previousViewController = tabItem.viewController
			}
			
			tabItem.expanded = !tabItem.expanded
			
			// If we've expanded a view controller
			if tabItem.expanded {
				tabItem.viewController.willMove(toParentViewController: self)
			} else {
				self.selectedTabIndex = nil
			}
			
			// View will move to logic!
			previousViewController?.willMove(toParentViewController: nil)
			tableView.reloadRows(at: redrawIndexPaths, with: .automatic)
			
			previousViewController?.removeFromParentViewController()
			previousViewController?.didMove(toParentViewController: nil)
			
			if tabItem.expanded {
				
				// Make sure to add child view controller!
				self.addChildViewController(tabItem.viewController)
				tabItem.viewController.didMove(toParentViewController: self)
				
				// Must do this otherwise pushing into details view doesn't work on tab > 0
				if let listPage = tabItem.viewController as? ListPage {
					listPage.data = listPage.data
				}
			}
		}
		
		data = [tabSection]
	}
	
	//MARK: -
	//MARK: - Helpers
	
	private func showPlaceholderViewController() {
		
		guard UI_USER_INTERFACE_IDIOM() == .pad, let selectedTabIndex = selectedTabIndex, selectedTabIndex < placeholders.count else { return }
		
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
		
		let placeholder = placeholders[selectedTabIndex]
		
		let placeholderVC = TSCPlaceholderViewController()
		placeholderVC.title = placeholder.title
		placeholderVC.placeholderDescription = placeholder.placeholderDescription
		placeholderVC.image = placeholder.image
		
		_splitViewController.detailViewController = UINavigationController(rootViewController: placeholderVC)
	}
	
	//MARK: -
	//MARK: - UITableViewDataSource
	
	override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		
		guard indexPath.row < tabBarItems.count else {
			return super.tableView(tableView, heightForRowAt: indexPath)
		}
		
		let tabItem = tabBarItems[indexPath.row]
		
		return tabItem.height(constrainedTo: .zero, in: tableView) ?? super.tableView(tableView, heightForRowAt: indexPath)
	}
	
	override open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		
		guard indexPath.row < tabBarItems.count else {
			return super.tableView(tableView, estimatedHeightForRowAt: indexPath)
		}
		
		let tabItem = tabBarItems[indexPath.row]
		
		return tabItem.height(constrainedTo: .zero, in: tableView) ?? super.tableView(tableView, estimatedHeightForRowAt: indexPath)
	}
	
	// We have to override this to fix it being set to false when iPad is in portrait
	open override var extendedLayoutIncludesOpaqueBars: Bool {
		get {
			return true
		}
		set {}
	}
}
