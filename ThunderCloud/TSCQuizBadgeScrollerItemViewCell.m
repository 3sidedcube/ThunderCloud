//
//  RCBadgeScrollerItemViewCell.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 27/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCQuizBadgeScrollerItemViewCell.h"
#import "NSString+LocalisedString.h"

@import ThunderBasics;
@import ThunderTable;

@interface TSCQuizBadgeScrollerItemViewCell ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *button;
@property (nonatomic, strong) UILabel *buttonLabel;
@property (nonatomic, strong) UIImageView *buttonImage;
@property (nonatomic, strong) UIImageView *bannerImage;

@end

@implementation TSCQuizBadgeScrollerItemViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.badgeImage = [UIImageView new];
        [self.contentView addSubview:self.badgeImage];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIEdgeInsets badgeImageInsets = UIEdgeInsetsMake(18, 15, 25, 15);
    CGFloat imageSize = MIN(self.contentView.bounds.size.width - badgeImageInsets.left - badgeImageInsets.right, self.contentView.bounds.size.height - badgeImageInsets.top - badgeImageInsets.bottom);
    
    self.badgeImage.frame = CGRectMake(badgeImageInsets.left, badgeImageInsets.top, imageSize, imageSize);
    self.badgeImage.center = CGPointMake(self.frame.size.width/2, self.bounds.size.height/2);
    
    if (self.completed) {
        self.badgeImage.alpha = 1.0;
    } else {
        self.badgeImage.alpha = 0.4;
    }
}

- (void)setCompleted:(BOOL)completed
{
    self.badgeImage.alpha = completed ? 1.0 : 0.4;
    _completed = completed;
}

@end
