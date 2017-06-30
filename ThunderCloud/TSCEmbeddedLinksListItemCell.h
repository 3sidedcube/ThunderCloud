//
//  TSCTableButtonViewCell.h
//  ThunderStorm
//
//  Created by Phillip Caudell on 04/12/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

/**
 `TSCEmbeddedLinksListItemCell` is a `TSCTableViewCell` that supports ebedded links. Each link is displayed as a button.
 */
@interface TSCEmbeddedLinksListItemCell : TSCStormTableViewCell

/**
 @abstract An array of `TSCLink`s to be displayed
 */
@property (nonatomic, strong) NSArray *links;

/**
 @abstract A BOOL to determine whether unavailable links should be hidden or not
 @discussion An unavailable link will be something like a call link on a devie that can't make calls
 */
@property (nonatomic, assign) BOOL hideUnavailableLinks;

/**
 @abstract An id of an object of which to call the selector on when the cell is selected
 */
@property (nonatomic, weak) id target;

/**
 @abstract A selector which is called on the target when the row is selected
 */
@property (nonatomic, assign) SEL selector;

/**
 Lays out the buttons in the cell
 */
- (void)layoutLinks;

@end
