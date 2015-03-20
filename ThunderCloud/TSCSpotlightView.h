//
//  TSCSpotlightView.h
//  ThunderStorm
//
//  Created by Andrew Hart on 12/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSCSpotlightView;

@protocol TSCSpotlightViewDelegate <NSObject>

- (NSInteger)numberOfItemsInSpotlightView:(TSCSpotlightView *)spotlightView;
- (UIImage *)spotlightView:(TSCSpotlightView *)spotlightView imageForItemAtIndex:(NSInteger)index;
- (NSInteger)delayForSpotlightAtIndex:(NSInteger)index;
- (NSString *)textForSpotlightAtIndex:(NSInteger)index;

@optional

- (void)spotlightView:(TSCSpotlightView *)spotlightView didReceiveTapOnIemAtIndex:(NSInteger)index;

@end

/**
 `TSCSpotlightView` is a view that manages and displayes all of the `TSCSpotlightImageListItemViewItem`s
 */
@interface TSCSpotlightView : UIView <UIScrollViewDelegate>

/**
 Reloads the all of the `TSCSpotlightImageListItemViewItem`s and lays them all back out
 */
- (void)reloadData;

/**
 @abstract A delegate for item selection call backs
 */
@property (nonatomic, weak) id <TSCSpotlightViewDelegate> spotlightDelegate;

/**
 @abstract The currently shown spotlight item
 */
@property (nonatomic) NSUInteger currentPage;

/**
 @abstract A `UIScrollView` that all of the `TSCSpotlightImageListItemViewItem`s are layed out in
 */
@property (nonatomic, strong) UIScrollView *scrollView;

/**
 @abstract An array of `UIImageView` which are created from the `TSCSpotlightImageListItemViewItem`s
 */
@property (nonatomic, strong) NSArray *imageViews;

/**
 @abstract A `UIPageControl` that displays which page the user is currently viewing
 */
@property (nonatomic, strong) UIPageControl *pageControl;

/**
 @abstract An `NSTimer` that is used to time the delays between srolling spotlights
 */
@property (nonatomic, strong) NSTimer *spotlightCycleTimer;

@end
