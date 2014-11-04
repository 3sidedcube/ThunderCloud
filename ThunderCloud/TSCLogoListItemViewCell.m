//
//  TSCLogoListItemViewCell.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 14/10/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCLogoListItemViewCell.h"

@implementation TSCLogoListItemViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];
        
    self.textLabel.alpha = 0.5;
    
    self.imageView.frame = CGRectMake(self.frame.size.width / 2 - 28, 10, 57, 55);
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.imageView.center = CGPointMake(self.frame.size.width / 2, self.imageView.center.y);
    
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.frame = CGRectMake(0, self.imageView.frame.origin.y + self.imageView.frame.size.height, self.frame.size.width, 44);
}

@end
