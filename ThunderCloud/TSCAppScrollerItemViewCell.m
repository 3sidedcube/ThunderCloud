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
    self = [super initWithFrame:frame];
    
    if (self) {
        
//        CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
//        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
//        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
//        UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
//        
//        self.backgroundColor = color;
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
