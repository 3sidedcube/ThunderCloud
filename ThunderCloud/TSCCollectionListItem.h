//
//  TSCCollectionListItemView.h
//  ThunderCloud
//
//  Created by Sam Houghton on 09/04/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSCSpotlightImageListItem.h"

/**
 Defines what the `TSCCollectionListItem` is displaying
 */
typedef NS_ENUM(NSInteger, TSCCollectionListItemViewType) {
    
    /** The collection view is displaying badges */
    TSCCollectionListItemViewQuizBadgeShowcase = 0,
    /** The collection view is displaying apps */
    TSCCollectionListItemViewAppShowcase = 1,
    /** The collection view is displaying links */
    TSCCollectionListItemViewLinkShowcase = 3
};

@interface TSCCollectionListItem : TSCListItem

/**
 @abstract Defines what the collection list item is displaying
 @see `TSCCollectionListItemViewType`
 */
@property (nonatomic) TSCCollectionListItemViewType type;

/**
 @abstract The array of badges to display in the collection
 */
@property (nonatomic, strong) NSMutableArray *badges;

/**
 @abstract The array of item to display in the collection
 */
@property (nonatomic, strong) NSMutableArray *objects;

@end
