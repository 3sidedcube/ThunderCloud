//
//  RCBadgeScrollerItemViewCell.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 27/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCBadgeScrollerItemViewCell.h"
#import "CAGradientLayer+AutoGradient.h"
@import ThunderBasics;
@import ThunderTable;

@interface TSCBadgeScrollerItemViewCell ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *button;
@property (nonatomic, strong) UILabel *buttonLabel;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIImageView *buttonImage;
@property (nonatomic, strong) UIImageView *bannerImage;

@end

@implementation TSCBadgeScrollerItemViewCell

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.badgeImage = [UIImageView new];
        [self.contentView addSubview:self.badgeImage];
        
        self.containerView = [[UIView alloc] init];
        self.containerView.backgroundColor = [UIColor whiteColor];
        self.containerView.layer.cornerRadius = 4.0f;
        self.containerView.layer.borderWidth = 0.5f;
        self.containerView.layer.borderColor = [UIColor colorWithWhite:0.75 alpha:1.0].CGColor;
        self.containerView.layer.shadowOffset = CGSizeMake(0, 1);
        self.containerView.layer.shadowRadius = 1;
        self.containerView.layer.shadowOpacity = 0.1;
        self.containerView.layer.masksToBounds = YES;
        
        [self addSubview:self.containerView];
        
        self.backgroundView = [[UIView alloc] init];
        self.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"starburst" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
        [self.containerView addSubview:self.backgroundView];
        
        self.badgeImage = [UIImageView new];
        
        [self.containerView addSubview:self.badgeImage];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont systemFontOfSize:19];
        [self.containerView addSubview:self.titleLabel];
        
        self.subtitleLabel = [[UILabel alloc] init];
        self.subtitleLabel.font = [UIFont systemFontOfSize:14];
        self.subtitleLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
        [self.containerView addSubview:self.subtitleLabel];
        
        self.button = [[UIView alloc] init];
        self.button.layer.cornerRadius = 4.0f;
        self.button.layer.borderWidth = 1.0f;
        self.button.layer.masksToBounds = YES;
        self.button.layer.borderColor = [[TSCThemeManager sharedTheme] mainColor].CGColor;
        self.button.layer.backgroundColor = [[TSCThemeManager sharedTheme] mainColor].CGColor;
        
        [self.containerView addSubview:self.button];
        
        self.buttonLabel = [[UILabel alloc] init];
        self.buttonLabel.font = [UIFont boldSystemFontOfSize:13];
        self.buttonLabel.text = @"BEGIN CHALLENGE";
        self.buttonLabel.textColor = [UIColor whiteColor];
        [self.button addSubview:self.buttonLabel];
        
        self.buttonImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chevron" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
        self.buttonImage.tintColor = [UIColor whiteColor];
        [self.button addSubview:self.buttonImage];
        
        self.bannerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sash" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
        [self addSubview:self.bannerImage];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    int borderSize = 15;
    self.badgeImage.frame = CGRectMake(borderSize, borderSize, self.contentView.bounds.size.width - (borderSize * 2), self.contentView.bounds.size.height - (borderSize * 2));
    
    [self.containerView setFrame:CGRectMake(0, 20, 320 - 30, 125)];
    [self.containerView setFrame:CGRectMake(self.contentView.bounds.size.width/2 - (self.containerView.frame.size.width/2), self.containerView.frame.origin.y, self.containerView.frame.size.width, self.containerView.frame.size.height)];
    self.backgroundView.frame = CGRectMake(0, -15, self.containerView.frame.size.width, self.containerView.frame.size.height + 15);
    
    self.badgeImage.frame = CGRectMake(10, 0, 70, 70);
    self.badgeImage.center = CGPointMake(self.badgeImage.center.x, self.containerView.frame.size.height / 2);
    
    [self.titleLabel setFrame:CGRectMake(self.badgeImage.frame.origin.x + self.badgeImage.frame.size.width + 15, 25, 170, 25)];
    
    [self.subtitleLabel setFrame:CGRectMake(self.titleLabel.frame.origin.x, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height - 2, self.titleLabel.frame.size.width, 18)];
    
    [self.button setFrame:CGRectMake(self.titleLabel.frame.origin.x, self.subtitleLabel.frame.origin.y + self.subtitleLabel.frame.size.height + 8, 160, 32)];
    
    // Add button gradient
//    CAGradientLayer *bgLayer = [CAGradientLayer generateGradientLayerWithTopColor:[UIColor colorWithRed:253/255.0f green:54/255.0f blue:56/255.0f alpha:1.0] bottomColor:[UIColor colorWithRed:249/255.0f green:0/255.0f blue:18/255.0f alpha:1.0]];
//    bgLayer.frame = self.button.bounds;
//    [self.button.layer insertSublayer:bgLayer atIndex:0];
    
    [self.buttonLabel sizeToFit];
    
    if (self.completed) {
        [self.button setFrame:CGRectMake(self.titleLabel.frame.origin.x, self.subtitleLabel.frame.origin.y + self.subtitleLabel.frame.size.height + 8, 90, 32)];
    }
    
    [self.buttonLabel setFrame:CGRectMake(6, 0, self.buttonLabel.frame.size.width, self.buttonLabel.frame.size.height)];
    self.buttonLabel.center = CGPointMake(self.buttonLabel.center.x, self.button.frame.size.height/2);
    
    [self.buttonImage setFrame:CGRectMake(self.buttonLabel.frame.origin.x + self.buttonLabel.frame.size.width, self.button.frame.size.height/2, 10, 16)];
    
    self.buttonImage.center = CGPointMake(self.buttonImage.center.x + 13, self.button.frame.size.height/2);
    
    if (self.completed) {
        self.buttonImage.frame = CGRectMake(self.buttonImage.frame.origin.x - 4, self.buttonImage.frame.origin.y, 15, 16);
    }
    
    if (self.completed) {
        [self.bannerImage setFrame:CGRectMake(self.containerView.frame.origin.x - 5, self.containerView.frame.origin.y - 5, self.bannerImage.frame.size.width, self.bannerImage.frame.size.height)];
        [self.bannerImage setFrame:CGRectMake(self.containerView.frame.origin.x - 5, self.containerView.frame.origin.y - 5, 51, 50)];
    } else {
        [self.bannerImage setFrame:CGRectMake(0, 0, 0, 0)];
    }
}

- (void)setCompleted:(BOOL)completed
{
    if (completed) {
        self.buttonLabel.text = TSCLanguageString(@"_QUIZ_COLLECTION_BUTTON_RETAKE");
        self.buttonImage.image = [UIImage imageNamed:@"reload" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    } else {
        self.buttonLabel.text = TSCLanguageString(@"_QUIZ_COLLECTION_BUTTON_BEGIN");
        self.buttonImage.image = [UIImage imageNamed:@"chevron" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    }
    
    _completed = completed;
}

@end