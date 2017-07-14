//
//  ListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// ListItem is the base object for displaying table rows in storm.
/// It complies to the `Row` protocol
open class ListItem: StormObject, Row {
	
	/// The title of the row
	open var title: String?
	
	/// The subtitle of the row
	/// The subtitle gets displayed under the title
	open var subtitle: String?
	
	/// A `TSCLink` which determines what the row does when it is selected
	open var link: TSCLink?
	
	/// The image for the row
	/// This is placed on the left hand side of the cell
	open var image: UIImage?
	
	/// The row's title text color
	open var titleTextColor: UIColor?
	
	/// The row's detail text color
	open var detailTextColor: UIColor?
	
	/// The `UINavigationController` of the view controller the row is displayed in
	var parentNavigationController: UINavigationController?
	
	required public init(dictionary: [AnyHashable : Any]) {
		
		super.init(dictionary: dictionary)
		
		if let titleDict = dictionary["title"] as? [AnyHashable : Any] {
			title = TSCLanguageController.shared().string(for: titleDict)
		}
		
		if let subtitleDict = dictionary["description"] as? [AnyHashable : Any] {
			subtitle = TSCLanguageController.shared().string(for: subtitleDict)
		}
		
		if let imageDict = dictionary["image"] as? NSObject {
			image = TSCImage.image(withJSONObject: imageDict)
		}
		
		if let linkDicationary = dictionary["link"] as? [AnyHashable : Any] {
			link = TSCLink(dictionary: linkDicationary)
		}
	}
	
	public func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		
		parentNavigationController = tableViewController.navigationController
		if link == nil {
			cell.accessoryType = .none
		}
		
		if let stormCell = cell as? StormTableViewCell {
			stormCell.parentViewController = tableViewController
		}
		
		if let _titleTextColor = titleTextColor {
			cell.textLabel?.textColor = _titleTextColor
			if let tCell = cell as? TableViewCell {
				tCell.cellTextLabel?.textColor = _titleTextColor
			}
		}
		
		if let _detailTextColor = detailTextColor {
			cell.detailTextLabel?.textColor = _detailTextColor
			if let tCell = cell as? TableViewCell {
				tCell.cellDetailLabel?.textColor = _detailTextColor
			}
		}
		
		
		if let tableCell = cell as? TableViewCell {
			tableCell.cellImageView?.isHidden = image == nil && imageURL == nil
			tableCell.cellTextLabel?.font = ThemeManager.shared.theme.cellTitleFont
			tableCell.cellDetailLabel?.font = ThemeManager.shared.theme.cellDetailFont
			tableCell.textLabel?.font = ThemeManager.shared.theme.cellTitleFont
			tableCell.detailTextLabel?.font = ThemeManager.shared.theme.cellDetailFont
		}
	}
	
	public var cellClass: AnyClass? {
		return StormTableViewCell.self
	}
	
	public var padding: CGFloat? {
		return 12.0
	}
	
	func handleSelection(of row: Row, at indexPath: IndexPath, in tableView: UITableView) {
		
		if let listPage = parentNavigationController?.visibleViewController as? ListPage {
			listPage.handleSelection(of: row, at: indexPath, in: tableView)
		}
	}
	
	public var selectionHandler: SelectionHandler? = { (row, wasSelection, indexPath, tableView) -> Void in
		
		guard let listItem = row as? ListItem, wasSelection else { return }
		
		listItem.handleSelection(of: row, at: indexPath, in: tableView)
	}
}
