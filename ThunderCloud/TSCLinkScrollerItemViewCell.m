//
//  TSCLinkScrollerItemViewCell.m
//  ThunderCloud
//
//  Created by Simon Mitchell on 28/10/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

#import "TSCLinkScrollerItemViewCell.h"

@implementation TSCLinkScrollerItemViewCell

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.imageView = [UIImageView new];
        self.imageView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:self.imageView];
        
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(0, 0, 57, 57);
    self.imageView.center = self.contentView.center;
}

@end
