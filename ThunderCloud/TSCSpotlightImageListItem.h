//
//  TSCSpotlightView.h
//  ThunderStorm
//
//  Created by Simon Mitchell on 11/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCListItem.h"
@import ThunderTable;

/**
 `TSCSpotlightImageListItem` is a model representation of a spotlight, it acts as a `TSCTableRowDataSource`
 @warning This class is now deprectated. Please use `TSCSpotlightListItem` instead.
 */
@interface TSCSpotlightImageListItem : TSCListItem /*<TSCTableRowDataSource>*/

/**
 @abstract An arrary of `TSCSpotlightImageListItemViewItem`s to be displayed
 */
@property (nonatomic, strong) NSMutableArray *items;

@end
