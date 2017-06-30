//
//  TSCCheckableListItemView.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 03/10/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCEmbeddedLinksListItem.h"

@class TSCEmbeddedLinksInputCheckItemCell;
@import UIKit;
@import ThunderTable;

/**
 `TSCCheckableListItem` is a subclass of TSCEmbeddedLinksListItem it reprents a table item that can be checked. It is rendered out as a `TSCEmbeddedLinksInputCheckItemCell`.
 */
@interface TSCCheckableListItem : TSCEmbeddedLinksListItem

/**
 @abstract The unique identifier of the cell
 @discussion The identifier is used for saving the state of the checked cell
 */
@property (nonatomic, strong) NSNumber *checkIdentifier;

/**
 @abstract The view that highlights when the cell is tappped
 */
//@property (nonatomic, strong) TSCCheckView *checkView;

@end
