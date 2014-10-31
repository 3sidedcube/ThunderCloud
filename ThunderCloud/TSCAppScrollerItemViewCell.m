//
//  TSCAppScrollerItemViewCell.m
//  ThunderCloud
//
//  Created by Matt Cheetham on 23/06/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import "TSCAppScrollerItemViewCell.h"

@implementation TSCAppScrollerItemViewCell

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.appIconView = [UIImageView new];
        self.appIconView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:self.appIconView];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.appIconView.frame = CGRectMake(0, 0, 57, 57);
    self.appIconView.center = self.contentView.center;
}

@end
