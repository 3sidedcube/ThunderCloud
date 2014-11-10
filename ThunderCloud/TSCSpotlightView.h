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

@interface TSCSpotlightView : UIView <UIScrollViewDelegate>

- (void)reloadData;

@property (nonatomic, weak) id <TSCSpotlightViewDelegate> spotlightDelegate;

@property (nonatomic) NSUInteger currentPage;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *imageViews;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSTimer *spotlightCycleTimer;

@end
