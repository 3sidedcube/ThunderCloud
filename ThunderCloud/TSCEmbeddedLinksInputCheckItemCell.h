//
//  TSCEmbeddedLinksListInputItemCell.h
//  ThunderCloud
//
//  Created by Simon Mitchell on 29/10/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

@import ThunderTable;

/**
 `TSCEmbeddedLinksInputCheckItemCell` is a `TSCTableInputCheckViewCell` that supports ebedded links. Each link is displayed as a button.
 */
@interface TSCEmbeddedLinksInputCheckItemCell : TSCTableInputCheckViewCell

/**
 @abstract An array of `TSCLink`s to be displayed
 */
@property (nonatomic, strong) NSArray *links;

/**
 @abstract A BOOL to determine whether unavailable links should be hidden or not
 @discussion An unavailable link will be something like a call link on a devie that can't make calls
 */
@property (nonatomic, assign) BOOL hideUnavailableLinks;

@end
