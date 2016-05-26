//
//  TSCSpotlightView.m
//  ThunderStorm
//
//  Created by Andrew Hart on 12/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCSpotlightView.h"
#import <QuartzCore/QuartzCore.h>
@import ThunderTable;

@interface TSCSpotlightView ()

@end

@implementation TSCSpotlightView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.scrollView = [[UIScrollView alloc] init];
        [self addSubview:self.scrollView];
        self.scrollView.pagingEnabled = YES;
        self.scrollView.delegate = self;
        
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.scrollsToTop = NO;
        
        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 16)];
        self.pageControl.currentPage = 0;
        [self.pageControl addTarget:self action:@selector(handlePageControlTapped) forControlEvents:UIControlEventTouchUpInside];
        self.pageControl.userInteractionEnabled = NO;
        [self addSubview:self.pageControl];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
        [self addGestureRecognizer:tapGesture];
    }
    
    return self;
}

- (void)handleTap
{
    if ([self.spotlightDelegate respondsToSelector:@selector(spotlightView:didReceiveTapOnIemAtIndex:)]) {
        [self.spotlightDelegate spotlightView:self didReceiveTapOnIemAtIndex:self.currentPage];
    }
}

- (void)handlePageControlTapped
{
    self.currentPage = self.pageControl.currentPage;
}

- (void)reloadData
{
    NSUInteger imageCount = [self.spotlightDelegate numberOfItemsInSpotlightView:self];
    
    self.pageControl.numberOfPages = imageCount;
    
    if (imageCount < 2) {
        self.pageControl.hidden = YES;
    } else {
        self.pageControl.hidden = NO;
    }
    
    while (self.imageViews.count > imageCount) {
        NSMutableArray *mutable = [NSMutableArray arrayWithArray:self.imageViews];
        [mutable removeLastObject];
        self.imageViews = mutable;
    }
    
    while (self.imageViews.count < imageCount) {
        NSMutableArray *mutable = [NSMutableArray arrayWithArray:self.imageViews];
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.masksToBounds = YES;
        [self.scrollView addSubview:imageView];
        [mutable addObject:imageView];
        self.imageViews = mutable;
    }
    
    for (UIImageView *imageView in self.imageViews) {
        NSUInteger i = [self.imageViews indexOfObject:imageView];
        imageView.image = [self.spotlightDelegate spotlightView:self imageForItemAtIndex:i];
    }
    
    [self layoutSubviews];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;
    
    NSUInteger imageCount = [self.spotlightDelegate numberOfItemsInSpotlightView:self];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * imageCount, self.scrollView.frame.size.height);
    
    for (UIImageView *imageView in self.imageViews) {
        NSUInteger i = [self.imageViews indexOfObject:imageView];
        imageView.frame = CGRectMake(self.scrollView.frame.size.width * i, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        
        [[imageView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        if (![[self.spotlightDelegate textForSpotlightAtIndex:i] isEqualToString:@""] && [self.spotlightDelegate textForSpotlightAtIndex:i]) {
            
            UIImage *spotlightImage = nil;
            
            spotlightImage = [UIImage imageNamed:@"SpotlightTextShadow" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            
            UIImageView *spotlightTextShadowImage = [[UIImageView alloc] initWithImage:spotlightImage];
            spotlightTextShadowImage.frame = imageView.bounds;
            [imageView addSubview:spotlightTextShadowImage];
        }
        
        UILabel *spotlightTextLabel = [[UILabel alloc] initWithFrame:imageView.bounds];
        spotlightTextLabel.text = [self.spotlightDelegate textForSpotlightAtIndex:i];
        spotlightTextLabel.font = [UIFont boldSystemFontOfSize:22];
        spotlightTextLabel.backgroundColor = [UIColor clearColor];
        spotlightTextLabel.textColor = [UIColor whiteColor];
        spotlightTextLabel.textAlignment = NSTextAlignmentCenter;
        spotlightTextLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        spotlightTextLabel.shadowOffset = CGSizeMake(0, 1);
        spotlightTextLabel.numberOfLines = 0;
        spotlightTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [imageView addSubview:spotlightTextLabel];
        
    }
    
    self.pageControl.frame = CGRectMake(0, self.frame.size.height - 20, self.frame.size.width, 12);
    
    [self setSpotlightTimer];
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float page = scrollView.contentOffset.x / scrollView.frame.size.width;
    
    self.currentPage = (NSUInteger)page;
}

#pragma mark - Setter methods

- (void)setCurrentPage:(NSUInteger)currentPage
{
    _currentPage = currentPage;
    
    self.pageControl.currentPage = currentPage;
    
    if (self.spotlightDelegate && [self.spotlightDelegate respondsToSelector:@selector(spotlightView:didShowItemAtIndex:)]) {
        [self.spotlightDelegate spotlightView:self didShowItemAtIndex:currentPage];
    }
    
    [self setSpotlightTimer];
}

#pragma mark - Timer handling

- (void)setSpotlightTimer
{
    if (!([self.spotlightDelegate numberOfItemsInSpotlightView:self] > self.currentPage)) {
        return;
    }
    
    if ([self.spotlightDelegate delayForSpotlightAtIndex:self.currentPage] != 0) {
        [self.spotlightCycleTimer invalidate];
        self.spotlightCycleTimer = [NSTimer scheduledTimerWithTimeInterval:[self.spotlightDelegate delayForSpotlightAtIndex:self.currentPage] / 1000 target:self selector:@selector(cycleSpotlight:) userInfo:nil repeats:NO];
    }
}

- (void)cycleSpotlight:(id)timer
{
    if (self.pageControl.currentPage + 1 == self.pageControl.numberOfPages) {
        [self.scrollView scrollRectToVisible:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height) animated:YES];
        self.currentPage = 0;
    } else {
        [self.scrollView scrollRectToVisible:CGRectMake(self.scrollView.contentOffset.x + self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height) animated:YES];
        self.currentPage++;
    }
}

@end
