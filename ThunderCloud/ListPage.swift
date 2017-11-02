//
//  ListPageViewController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 06/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import MobileCoreServices

/// `ListPage` is a subclass of `TableViewController` that lays out storm table view content
open class ListPage: TableViewController, StormObjectProtocol, TSCCoreSpotlightIndexItem {

    //MARK: -
	//MARK: Public API
	//MARK: -
	
	/// An array of dictionaries which contain custom attributes fot the `StormObject`
	public var attributes: [[AnyHashable : Any]]?
	
	/// The unique identifier for the storm page
	public var pageId: String?
	
	/// selectionHandler is called when an item in the table view is selected.
	/// An action is performed based on the `TSCLink` which is passed in with the selection.
	/// handleSelection is called when an item in the table view is selected.
	///
	/// An action is performed based on the `TSCLink` which is passed in with the row.
	///
	/// - Parameters:
	///   - row: The row which was selected
	///   - indexPath: The indexPath of that row
	///   - tableView: The table view the selection happened at
	open func handleSelection(of row: Row, at indexPath: IndexPath, in tableView: UITableView) {
		
		guard let stormRow = row as? ListItem, let link = stormRow.link else { return }
		navigationController?.push(link: link)
	}
	
	/// The internal page name for this page.
	/// Named pages can be used for native overrides and for identifying
	/// pages that may change ID with delta publishes.
	/// By default this is nil, but name can be added in the CMS
	public var pageName: String?
	
	public convenience init?(contentsOf url: URL) {
		
		guard let data = try? Data(contentsOf: url) else { return nil }
		guard let pageObject = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }
		guard let pageDictionary = pageObject as? [AnyHashable : Any] else { return nil }
		
		self.init(dictionary: pageDictionary)
	}
	
	private let dictionary: [AnyHashable : Any]
	
	public required init(dictionary: [AnyHashable : Any]) {
		
		self.dictionary = dictionary
		
		super.init(style: .grouped)
		
		attributes = dictionary["attributes"] as? [[AnyHashable : Any]]
		
		if let titleDict = dictionary["title"] as? [AnyHashable : Any], let titleContentKey = titleDict["content"] as? String {
			title = StormLanguageController.shared.string(for: titleContentKey)
		}
		
		pageName = dictionary["name"] as? String
		
		if let pageNumberId = dictionary["id"] as? Int {
			pageId = "\(pageNumberId)"
		} else {
			pageId = dictionary["id"] as? String
		}
	}
	
	required public init?(coder aDecoder: NSCoder) {
		dictionary = [:]
		super.init(coder: aDecoder)
	}
	
	//MARK: -
	//MARK: View Controller Lifecycle
	//MARK: -
	
	override open func viewDidLoad() {
		
		super.viewDidLoad()
		view.backgroundColor = ThemeManager.shared.theme.backgroundColor
		
		guard let children = dictionary["children"] as? [[AnyHashable : Any]] else { return }
		
		data = children.flatMap { (child) -> Section? in
			return StormObjectFactory.shared.stormObject(with: child) as? Section
		}
	}
	
	//MARK: -
	//MARK: TSCCoreSpotlightIndexItem
	//MARK: -
	public func searchableAttributeSet() -> CSSearchableItemAttributeSet! {
		
		guard let children = dictionary["children"] as? [[AnyHashable : Any]] else { return nil }
		let sections = children.flatMap { (child) -> Section? in
			return StormObjectFactory.shared.stormObject(with: child) as? Section
		}
		
		if sections.count > 0 {
			
			let searchableAttributeSet = CSSearchableItemAttributeSet(itemContentType: String(kUTTypeData))
			searchableAttributeSet.title = title
			
			let rows: [Row] = sections.flatMap({ (section) -> [Row] in
				return section.rows
			})
			
			// Loop through each row until we've added a title and image to the searchable attribute set (Can't use for each as we need to break out)
			for row in rows {
				
				if let rowTitle = row.title, searchableAttributeSet.contentDescription == nil {
					
					if let subtitle = row.subtitle {
						searchableAttributeSet.contentDescription = rowTitle + "\n\n\(subtitle)"
					} else {
						searchableAttributeSet.contentDescription = rowTitle
					}
				}
				
				if let rowImage = row.image, searchableAttributeSet.thumbnailData == nil {
					searchableAttributeSet.thumbnailData = UIImageJPEGRepresentation(rowImage, 0.1)
				}
				
				if searchableAttributeSet.contentDescription != nil && searchableAttributeSet.thumbnailData != nil {
					break
				}
			}
			
			return searchableAttributeSet
		}
		
		return nil
	}
}
