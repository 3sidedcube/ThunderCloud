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
    self = [super initWithFrame:frame];
    
    if (self) {
        
        //        CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
        //        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
        //        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
        //        UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
        //
        //        self.backgroundColor = color;
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
