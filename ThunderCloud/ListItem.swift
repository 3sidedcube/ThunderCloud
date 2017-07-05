//
//  ListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// ListItem is the base object for displaying table rows in storm.
/// It complies to the `Row` protocol
class ListItem: StormObject, Row {
	
	/// The title of the row
	var title: String?
	
	/// The subtitle of the row
	/// The subtitle gets displayed under the title
	var subtitle: String?
	
	/// A `TSCLink` which determines what the row does when it is selected
	var link: TSCLink?
	
	/// The image for the row
	/// This is placed on the left hand side of the cell
	var image: UIImage?
	
	/// The `UINavigationController` of the view controller the row is displayed in
	var parentNavigationController: UINavigationController?
	
	required init(dictionary: [AnyHashable : Any], parentObject: StormObjectProtocol?) {
		
		super.init(dictionary: dictionary, parentObject: parentObject)
		
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
	
	func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		
		//TODO: Add back in!
		//		parentNavigationController = cell.parentViewController.navigationController
		if link == nil {
			cell.accessoryType = .none
		}
	}
	
	var cellClass: AnyClass? {
		return StormTableViewCell.self
	}
	
	var padding: CGFloat? {
		return 12.0
	}

	//TODO: Implement somehow!
//	- (SEL)rowSelectionSelector
//	{
//	return NSSelectorFromString(@"handleSelection:");
//	}
//	
//	- (id)rowSelectionTarget
//	{
//	return [self stormParentObject];
//	}
}
