//
//  TSCLocalisationExplanationViewController.m
//  ThunderCloud
//
//  Created by Simon Mitchell on 18/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

#import "TSCLocalisationExplanationViewController.h"

@import ThunderTable;

@interface TSCLocalisationExplanationViewController ()

@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *greenLabel;
@property (nonatomic, strong) UIImageView *greenImageView;

@property (nonatomic, strong) UILabel *amberLabel;
@property (nonatomic, strong) UIImageView *amberImageView;

@property (nonatomic, strong) UILabel *redLabel;
@property (nonatomic, strong) UIImageView *redImageView;

@property (nonatomic, strong) UILabel *otherLabel;

@end

@implementation TSCLocalisationExplanationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([TSCThemeManager isOS8]) {
        
        UIVisualEffect *darkBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.backgroundView = [[UIVisualEffectView alloc] initWithEffect:darkBlur];
    } else {
        
        self.backgroundView = [UIView new];
        self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
    }
    
    [self.view addSubview:self.backgroundView];
    
    self.moreButton = [UIButton new];
    
    UIImage *buttonImage = [UIImage imageNamed:@"localisations-morebutton-rotated" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    [self.moreButton setImage:buttonImage forState:UIControlStateNormal];
    [self.moreButton addTarget:self action:@selector(handleDismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.moreButton];
    
    self.titleLabel = [UILabel new];
    self.titleLabel.text = @"Tap a highlighted localisation to get editing!";
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.titleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    [self.view addSubview:self.titleLabel];
    
    self.greenLabel = [UILabel new];
    self.greenLabel.text = @"A localisation is highlighted green if it's up to date with the value in the CMS.";
    self.greenLabel.numberOfLines = 0;
    self.greenLabel.font = [UIFont systemFontOfSize:14];
    self.greenLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    [self.view addSubview:self.greenLabel];
    
    self.greenImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"localisations-green-light" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
    [self.view addSubview:self.greenImageView];
    
    self.amberLabel = [UILabel new];
    self.amberLabel.text = @"A localisation is highlighted amber if the localisation in the app isn't the same as the one in the CMS.";
    self.amberLabel.numberOfLines = 0;
    self.amberLabel.font = [UIFont systemFontOfSize:14];
    self.amberLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    [self.view addSubview:self.amberLabel];
    
    self.amberImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"localisations-amber-light" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
    [self.view addSubview:self.amberImageView];
    
    self.redLabel = [UILabel new];
    self.redLabel.text = @"A localisation is highlighted red if it hasn't yet been added to the CMS yet.";
    self.redLabel.numberOfLines = 0;
    self.redLabel.font = [UIFont systemFontOfSize:14];
    self.redLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    [self.view addSubview:self.redLabel];
    
    self.redImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"localisations-red-light" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
    [self.view addSubview:self.redImageView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.moreButton.frame = CGRectMake(8, 26, 44, 44);
    
    CGFloat titleX = CGRectGetMaxX(self.moreButton.frame) + 8;
    CGSize titleSize = [self.titleLabel sizeThatFits:CGSizeMake(self.view.bounds.size.width - titleX - 20, MAXFLOAT)];
    self.titleLabel.frame = CGRectMake(titleX, 0, self.view.bounds.size.width - titleX - 20, titleSize.height);
    self.titleLabel.center = CGPointMake(self.titleLabel.center.x, self.moreButton.center.y);
    
    CGSize greenLabelSize = [self.greenLabel sizeThatFits:CGSizeMake(self.view.bounds.size.width - (titleX - 10) - 20, MAXFLOAT)];
    self.greenLabel.frame = CGRectMake(titleX - 10, CGRectGetMaxY(self.moreButton.frame) + 12, self.view.bounds.size.width - (titleX - 10) - 20, greenLabelSize.height);
    self.greenImageView.frame = CGRectMake(0, 0, 20, 20);
    self.greenImageView.center = CGPointMake(self.moreButton.center.x, self.greenLabel.center.y);
    
    CGSize amberLabelSize = [self.amberLabel sizeThatFits:CGSizeMake(self.greenLabel.frame.size.width, MAXFLOAT)];
    self.amberLabel.frame = CGRectMake(self.greenLabel.frame.origin.x, CGRectGetMaxY(self.greenLabel.frame) + 20, self.greenLabel.frame.size.width, amberLabelSize.height);
    self.amberImageView.frame = CGRectMake(0, 0, 20, 20);
    self.amberImageView.center = CGPointMake(self.moreButton.center.x, self.amberLabel.center.y);
    
    CGSize redLabelSize = [self.redLabel sizeThatFits:CGSizeMake(self.greenLabel.frame.size.width, MAXFLOAT)];
    self.redLabel.frame = CGRectMake(self.greenLabel.frame.origin.x, CGRectGetMaxY(self.amberLabel.frame) + 20, self.greenLabel.frame.size.width, redLabelSize.height);
    self.redImageView.frame = CGRectMake(0, 0, 20, 20);
    self.redImageView.center = CGPointMake(self.moreButton.center.x, self.redLabel.center.y);
    
    self.backgroundView.frame = self.view.bounds;
}

- (void)handleDismiss
{
    if (self.TSCLocalisationDismissHandler) {
        self.TSCLocalisationDismissHandler();
    }
}

@end
