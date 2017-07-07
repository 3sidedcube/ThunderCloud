//
//  TextListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// `TextListItem` is a subclass of `ListItem` which represents a row with just a subtitle.
/// It is normally used for displaying multiple lines of text.
/// Note it is an adapter for the object in the cms, all logic is done on it's superclass
class TextListItem: ListItem {
	
	//TODO: Implement!

//	- (UIColor *)rowTitleTextColor
//	{
//	return [UIColor darkGrayColor];
//	}
//	
//	- (Class)tableViewCellClass
//	{
//	return [TSCTextListItemViewCell class];
//	}
//	
//	- (BOOL)shouldDisplaySelectionCell
//	{
//	return NO;
//	}
//	
//	- (BOOL)shouldDisplaySelectionIndicator
//	{
//	return NO;
//	}
	
	override var cellClass: AnyClass? {
		return TextListItemCell.self
	}
}
