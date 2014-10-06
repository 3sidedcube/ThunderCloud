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

@protocol TSCSpotlightImageListItemViewCellDelegate

- (void)spotlightViewCell:(TSCSpotlightImageListItemViewCell *)cell didReceiveTapOnItemAtIndex:(int)index;

@end

@interface TSCSpotlightImageListItemViewCell : TSCTableViewCell <TSCSpotlightViewDelegate>

@property (nonatomic, strong) TSCSpotlightView *spotlightView;

@property (nonatomic, strong) NSArray *items;

@property (nonatomic, weak) id <TSCSpotlightImageListItemViewCellDelegate> delegate;

@property (nonatomic, strong) NSTimer *spotlightCycleTimer;

@end