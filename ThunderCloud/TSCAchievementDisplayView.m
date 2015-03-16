//
//  TSCAchievementDisplayView.m
//  Swim
//
//  Created by Andrew Hart on 20/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@import ThunderBasics;
#import "TSCAchievementDisplayView.h"
#import "NSString+LocalisedString.h"

@interface TSCAchievementDisplayView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *badgeImageView;

@end

@implementation TSCAchievementDisplayView

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image subtitle:(NSString *)subtitle
{
    if (self = [super initWithFrame:frame]) {
        
        self.badgeImageView = [[UIImageView alloc] initWithImage:image];
        [self addSubview:self.badgeImageView];
        
        self.titleLabel = [UILabel new];
        self.titleLabel.text = [NSString stringWithLocalisationKey:@"_QUIZ_WIN_CONGRATULATION" fallbackString:@"Congratulations!"];
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
    
    self.badgeImageView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    
    self.titleLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.badgeImageView.frame.origin.y);
    
    self.subtitleLabel.frame = CGRectMake(12, CGRectGetMaxY(self.badgeImageView.frame), self.frame.size.width - (2*12), 170);
    
    [self.subtitleLabel sizeToFit];
    
    self.subtitleLabel.frame = CGRectMake(self.subtitleLabel.frame.origin.x, self.subtitleLabel.frame.origin.y, self.frame.size.width - (2*12), self.subtitleLabel.frame.size.height + 20);
}

@end
