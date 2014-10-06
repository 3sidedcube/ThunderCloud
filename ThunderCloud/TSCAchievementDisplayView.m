//
//  TSCAchievementDisplayView.m
//  Swim
//
//  Created by Andrew Hart on 20/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@import ThunderBasics;
#import "TSCAchievementDisplayView.h"

@interface TSCAchievementDisplayView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextView *subtitleLabel;
@property (nonatomic, strong) UIImageView *badgeImageView;

@end

@implementation TSCAchievementDisplayView

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image subtitle:(NSString *)subtitle
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.badgeImageView = [[UIImageView alloc] initWithImage:image];
        [self addSubview:self.badgeImageView];
        
        self.titleLabel = [UILabel new];
        self.titleLabel.text = TSCLanguageString(@"_QUIZ_WIN_CONGRATULATION");
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];
        
        self.subtitleLabel = [UITextView new];
        self.subtitleLabel.text = subtitle;
        self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
        self.subtitleLabel.backgroundColor = [UIColor clearColor];
        self.subtitleLabel.font = self.titleLabel.font;
        [self addSubview:self.subtitleLabel];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.badgeImageView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    
    self.titleLabel.frame = CGRectMake(0, 0, self.bounds.size.width, self.badgeImageView.frame.origin.y);
    
    self.subtitleLabel.frame = CGRectMake(12, CGRectGetMaxY(self.badgeImageView.frame), self.bounds.size.width - (2*12), 170);
}

@end
