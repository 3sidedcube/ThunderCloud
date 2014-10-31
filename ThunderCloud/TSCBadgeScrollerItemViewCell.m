//
//  RCBadgeScrollerItemViewCell.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 27/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCBadgeScrollerItemViewCell.h"

@implementation TSCBadgeScrollerItemViewCell

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.badgeImage = [UIImageView new];
        [self.contentView addSubview:self.badgeImage];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    int borderSize = 15;
    self.badgeImage.frame = CGRectMake(borderSize, borderSize, self.contentView.bounds.size.width - (borderSize * 2), self.contentView.bounds.size.height - (borderSize * 2));
}

@end