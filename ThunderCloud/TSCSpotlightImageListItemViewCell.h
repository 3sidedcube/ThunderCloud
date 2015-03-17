//
//  TSCSpotlightImageListItemViewCell.h
//  ThunderStorm
//
//  Created by Andrew Hart on 11/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@import ThunderTable;

#import "TSCSpotlightImageListItemViewItem.h"
#import "TSCSpotlightView.h"

@class TSCSpotlightImageListItemViewCell;

/**
 `TSCSpotlightImageListItemViewCellDelegate` is delegate used to call back when a spotlight cell is selected
 */
@protocol TSCSpotlightImageListItemViewCellDelegate

/**
 Calls back when a the spotlight is selected
 @param cell The `TSCSpotlightImageListItemViewCell` that was selected
 @param index The index of the `TSCSpotlightImageListItemViewItem` that was selected
 */
- (void)spotlightViewCell:(TSCSpotlightImageListItemViewCell *)cell didReceiveTapOnItemAtIndex:(NSInteger)index;

@end

/**
 `TSCSpotlightImageListItemViewCell` is a `TSCTableViewCell` that represents a spotlight. It contains a `TSCSpotlightView`
 */
@interface TSCSpotlightImageListItemViewCell : TSCTableViewCell <TSCSpotlightViewDelegate>

/**
 @abstract A `TSCSpotlightView` that is contained in the cell
 @discussion The spotlight view lays out the individual spolight items and manages their scrolling
 */
@property (nonatomic, strong) TSCSpotlightView *spotlightView;

/**
 @abstract An array of `TSCSpotlightImageListItemViewItem`s
 */
@property (nonatomic, strong) NSArray *items;

/**
 @abstract A `TSCSpotlightImageListItemViewCellDelegate` that callback when a spotlight is selected
 */
@property (nonatomic, weak) id <TSCSpotlightImageListItemViewCellDelegate> delegate;

/**
 @abstract An `NSTimer` that is used to time the delays between srolling spotlights
 */
@property (nonatomic, strong) NSTimer *spotlightCycleTimer;

@end