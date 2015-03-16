//
//  TSCAppScrollerItemViewCell.m
//  ThunderCloud
//
//  Created by Matt Cheetham on 23/06/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import "TSCAppScrollerItemViewCell.h"

@implementation TSCAppScrollerItemViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.appIconView = [UIImageView new];
        [self.contentView addSubview:self.appIconView];
        
        self.nameLabel = [UILabel new];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.nameLabel];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.appIconView.frame = CGRectMake(0, 0, 57, 57);
    self.appIconView.center = CGPointMake(self.contentView.center.x, self.contentView.center.y - 10);
    
    self.nameLabel.frame = CGRectMake(0, self.appIconView.frame.size.height + self.appIconView.frame.origin.y, self.contentView.frame.size.width, 25);
}

@end
