//
//  TSCSpotlightImageListItemViewItem.h
//  ThunderStorm
//
//  Created by Andrew Hart on 11/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCStormObject.h"
@import UIKit;

@class TSCLink;

/**
 `TSCSpotlightImageListItemViewItem` is a view that represents an item in the spotlight.
 */
@interface TSCSpotlightImageListItemViewItem : TSCStormObject

/**
 @abstract A `UIImage` that is displayed for the spolight
 */
@property (nonatomic, strong) UIImage *image;

/**
 @abstract A `TSCLink` used to perform an action when an item is selected
 */
@property (nonatomic, strong) TSCLink *link;

/**
 @abstract An Interger of time to determine how long the item is displayed on screen for
 */
@property (assign) NSInteger delay;

/**
 @abstract A string of text that is displayed across the center of the spotlight item
 */
@property (nonatomic, copy) NSString *spotlightText;

@end
