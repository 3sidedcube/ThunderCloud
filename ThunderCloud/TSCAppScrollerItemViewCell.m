//
//  TSCAppScrollerItemViewCell.m
//  ThunderCloud
//
//  Created by Matt Cheetham on 23/06/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import "TSCAppScrollerItemViewCell.h"
@import ThunderTable;
@import ThunderBasics;

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
        
        self.priceLabel = [UILabel new];
        self.priceLabel.textColor = [TSCThemeManager shared].theme.secondaryColor;
        self.priceLabel.font = [UIFont systemFontOfSize:14];
        self.priceLabel.numberOfLines = 0;
        self.priceLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.priceLabel];
        
        self.appIconView.contentMode = UIViewContentModeRedraw;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.appIconView.frame = CGRectMake(0, 8, 68, 68);
    [self.appIconView setCenterX:self.bounds.size.width/2];
    
    if (self.priceLabel.text) {
        self.nameLabel.frame = CGRectMake(0, self.appIconView.frame.size.height + self.appIconView.frame.origin.y, self.contentView.frame.size.width, 25);
    } else {
        self.nameLabel.frame = CGRectMake(0, self.appIconView.frame.size.height + self.appIconView.frame.origin.y + 12, self.contentView.frame.size.width, 25);
    }

    [self.priceLabel sizeToFit];
    [self.priceLabel setY:CGRectGetMaxY(self.nameLabel.frame)-4];
    [self.priceLabel setWidth:self.nameLabel.frame.size.width];
    [self.priceLabel setCenterX:self.nameLabel.center.x];
}

@end
