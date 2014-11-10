//
//  TSCQuizCollectionViewCell.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 14/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCQuizCollectionViewCell.h"

@implementation TSCQuizCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor lightGrayColor];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.font = [UIFont boldSystemFontOfSize:16];
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        self.gradientImageView = [[UIImageView alloc] init];
        self.gradientImageView.image = [UIImage imageNamed:@"NameLabel-bg" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
        [self.contentView addSubview:self.gradientImageView];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = self.contentView.bounds;
    self.imageView.layer.cornerRadius = 0;
    self.textLabel.frame = CGRectMake(0, self.imageView.frame.origin.y + self.imageView.frame.size.height - 30, self.contentView.bounds.size.width, 20);
    self.gradientImageView.frame = CGRectMake(0, self.frame.size.height - 53, self.frame.size.width, 53);
    
    [self.contentView bringSubviewToFront:self.textLabel];
}

@end
