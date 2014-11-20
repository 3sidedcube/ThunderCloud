//
//  TSCLogoListItemViewCell.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 14/10/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCLogoListItemViewCell.h"

@implementation TSCLogoListItemViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
        
    self.textLabel.alpha = 0.5;
    
    CGFloat aspectRatio = self.imageView.image.size.height/self.imageView.image.size.width;
    CGFloat width = MIN(self.contentView.frame.size.width-30, self.imageView.image.size.width);
    CGFloat height = aspectRatio*width;
    
    self.imageView.frame = CGRectMake(self.frame.size.width / 2 - width/2, 10, width, height);
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.imageView.center = CGPointMake(self.frame.size.width / 2, self.imageView.center.y);
    
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.frame = CGRectMake(0, self.imageView.frame.origin.y + self.imageView.frame.size.height, self.frame.size.width, 44);
    
}

@end
