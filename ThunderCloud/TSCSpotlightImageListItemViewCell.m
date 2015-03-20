//
//  TSCSpotlightImageListItemViewCell.m
//  ThunderStorm
//
//  Created by Andrew Hart on 11/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCSpotlightImageListItemViewCell.h"

@interface TSCSpotlightImageListItemViewCell ()

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation TSCSpotlightImageListItemViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView addSubview:self.scrollView];
        
        Class spotlightClass = [TSCStormObject classForClassKey:@"TSCSpotlightView"];
        
        self.spotlightView = [[spotlightClass alloc] initWithFrame:self.bounds];
        self.spotlightView.spotlightDelegate = self;
        [self.contentView addSubview:self.spotlightView];
        
        if (![TSCThemeManager isOS7]) {
            self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        }
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.spotlightView.frame = self.bounds;
    
    if (![TSCThemeManager isOS7]) {
        self.spotlightView.frame = CGRectMake(-10, 0, self.spotlightView.frame.size.width, self.spotlightView.frame.size.height);
    }
}

#pragma mark - TSCSpotlightViewDelegate methods

- (NSInteger)numberOfItemsInSpotlightView:(TSCSpotlightView *)spotlightView
{
    return [self.items count];
}

- (UIImage *)spotlightView:(TSCSpotlightView *)spotlightView imageForItemAtIndex:(NSInteger)index
{
    TSCSpotlightImageListItemViewItem *item = [self.items objectAtIndex:index];
    
    return item.image;
}

- (void)spotlightView:(TSCSpotlightView *)spotlightView didReceiveTapOnIemAtIndex:(NSInteger)index
{
    [self.delegate spotlightViewCell:self didReceiveTapOnItemAtIndex:index];
}

- (NSInteger)delayForSpotlightAtIndex:(NSInteger)index
{
    if (index < self.items.count) {
        return [(TSCSpotlightImageListItemViewItem * )self.items[index] delay];
    }
    
    return 5;
}

- (NSString *)textForSpotlightAtIndex:(NSInteger)index
{
    return [(TSCSpotlightImageListItemViewItem * )self.items[index] spotlightText];
}

#pragma mark - Setter methods

- (void)setItems:(NSArray *)items
{
    _items = items;
    
    [self.spotlightView reloadData];
}

@end