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
    
    self.cellTextLabel.alpha = 0.5;
    
    CGFloat aspectRatio = self.cellImageView.image.size.height/self.cellImageView.image.size.width;
    CGFloat width = MIN(self.contentView.frame.size.width-30, self.cellImageView.image.size.width);
    CGFloat height = aspectRatio*width;
    
    if (!isnan(height)) {
        self.cellImageView.frame = CGRectMake(self.frame.size.width / 2 - width/2, 10, width, height);
    }
    
    self.cellImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.cellImageView.center = CGPointMake(self.frame.size.width / 2, self.cellImageView.center.y);
    
    self.cellTextLabel.textAlignment = NSTextAlignmentCenter;
    self.cellTextLabel.frame = CGRectMake(0, self.cellImageView.frame.origin.y + self.cellImageView.frame.size.height, self.frame.size.width, 44);
    
}

@end
