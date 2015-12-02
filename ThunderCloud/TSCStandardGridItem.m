//
//  TSCStandardGridItem.m
//  ThunderCloud
//
//  Created by Sam Houghton on 16/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

#import "TSCStandardGridItem.h"

@implementation TSCStandardGridItem

#define TEXT_AREA_HEIGHT 32

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.imageView = [[UIImageView alloc] init];
        self.imageView.clipsToBounds = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.imageView];
        
        self.textLabel = [UILabel new];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.textColor = [UIColor colorWithRed:73.0 / 255.0 green:73.0 / 255.0 blue:73.0 / 255.0 alpha:1.0];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [UIFont systemFontOfSize:17];
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.contentView addSubview:self.textLabel];
        self.textLabel.numberOfLines = 100;
        
        self.detailTextLabel = [UILabel new];
        self.detailTextLabel.textAlignment = NSTextAlignmentCenter;
        self.detailTextLabel.textColor = [UIColor colorWithRed:166.0 / 255.0 green:167.0 / 255.0 blue:169.0 / 255.0 alpha:1.0];
        self.detailTextLabel.font = [UIFont systemFontOfSize:14];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.detailTextLabel];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat imageWidth = (self.contentView.bounds.size.width * 0.85);
    
    if (imageWidth > self.contentView.frame.size.height) {
        imageWidth = ((self.contentView.bounds.size.height / 3) * 2);
    }
    
    if (self.detailTextLabel.text) {
        
        self.imageView.frame = CGRectMake(20, 20, self.contentView.frame.size.height - 100, self.contentView.frame.size.height - 100);
        self.imageView.center = CGPointMake(self.contentView.frame.size.width / 2, self.imageView.center.y);
        self.textLabel.frame = CGRectMake(0, CGRectGetMaxY(self.imageView.frame) + 10, CGRectGetWidth(self.bounds), 22);
        self.detailTextLabel.frame = CGRectMake(0, CGRectGetMaxY(self.textLabel.frame), CGRectGetWidth(self.bounds), 22);
        
    } else {
        
        self.imageView.frame = CGRectMake(20, 20, self.contentView.frame.size.height - 65, self.contentView.frame.size.height - 65);
        self.imageView.center = CGPointMake(self.contentView.frame.size.width / 2, self.imageView.center.y);
        self.textLabel.frame = CGRectMake(0, CGRectGetMaxY(self.imageView.frame) + 5, CGRectGetWidth(self.bounds), 22);
        
    }
}

@end
