//
//  TSCLocalisationExplanationViewController.m
//  ThunderCloud
//
//  Created by Simon Mitchell on 18/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

#import "TSCLocalisationExplanationViewController.h"
#import "TSCLocalisationController.h"
#import "NSString+LocalisedString.h"
#import <ThunderCloud/ThunderCloud-Swift.h>

@import ThunderBasics;

#define DegreesToRadians(x) ((x) * M_PI / 180.0)

@import ThunderTable;

@interface TSCLocalisationExplanationViewController () <TSCLocalisationEditViewControllerDelegate>

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
@property (nonatomic, strong) UIButton *otherButton;

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, assign) BOOL viewHasAppeared;

@end

@implementation TSCLocalisationExplanationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	UIVisualEffect *darkBlur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
	self.backgroundView = [[UIVisualEffectView alloc] initWithEffect:darkBlur];

    self.backgroundView.alpha = 0.0;
    [self.view addSubview:self.backgroundView];
    
    self.moreButton = [UIButton new];
    
    self.containerView = [UIView new];
    self.containerView.alpha = 0.0;
    [self.view addSubview:self.containerView];
    
    UIImage *buttonImage = [UIImage imageNamed:@"localisations-morebutton" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    [self.moreButton setImage:buttonImage forState:UIControlStateNormal];
    [self.moreButton addTarget:self action:@selector(handleDismiss) forControlEvents:UIControlEventTouchUpInside];
    
    self.titleLabel = [UILabel new];
    self.titleLabel.text = @"Tap a highlighted localisation to get editing!";
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.titleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    [self.containerView addSubview:self.titleLabel];
    
    self.greenLabel = [UILabel new];
    self.greenLabel.text = @"A localisation is highlighted green if it's up to date with the value in the CMS.";
    self.greenLabel.numberOfLines = 0;
    self.greenLabel.font = [UIFont systemFontOfSize:14];
    self.greenLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    [self.containerView addSubview:self.greenLabel];
    
    self.greenImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"localisations-green-light" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
    self.greenImageView.alpha = 0.0;
    [self.view addSubview:self.greenImageView];
    
    self.amberLabel = [UILabel new];
    self.amberLabel.text = @"A localisation is highlighted amber if the localisation in the app isn't the same as the one in the CMS.";
    self.amberLabel.numberOfLines = 0;
    self.amberLabel.font = [UIFont systemFontOfSize:14];
    self.amberLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    [self.containerView addSubview:self.amberLabel];
    
    self.amberImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"localisations-amber-light" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
    self.amberImageView.alpha = 0.0;
    [self.view addSubview:self.amberImageView];
    
    self.redLabel = [UILabel new];
    self.redLabel.text = @"A localisation is highlighted red if it hasn't yet been added to the CMS yet.";
    self.redLabel.numberOfLines = 0;
    self.redLabel.font = [UIFont systemFontOfSize:14];
    self.redLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    [self.containerView addSubview:self.redLabel];
    
    self.redImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"localisations-red-light" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
    self.redImageView.alpha = 0.0;
    [self.view addSubview:self.redImageView];
    
    self.otherButton = [[UIButton alloc] init];
    [self.otherButton setTitle:@"Other Localisations" forState:UIControlStateNormal];
    self.otherButton.layer.backgroundColor = [UIColor colorWithHexString:@"3892DF"].CGColor;
    self.otherButton.layer.cornerRadius = 4.0;
    self.otherButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.otherButton.layer.borderWidth = 2.0;
    [self.otherButton addTarget:self action:@selector(handleAdditionalStrings:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.otherButton];
    self.containerView.userInteractionEnabled = true;
    
    self.otherLabel = [UILabel new];
    self.otherLabel.font = [UIFont systemFontOfSize:14];
    self.otherLabel.text = @"View any localisations we didn't manage to highlight for you here";
    self.otherLabel.textAlignment = NSTextAlignmentCenter;
    self.otherLabel.numberOfLines = 0;
    self.otherLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.otherLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    [self.containerView addSubview:self.otherLabel];
    
    [self.view addSubview:self.moreButton];
    
    self.otherButton.alpha = 0.0;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.moreButton.frame = CGRectMake(8, 26, 44, 44);
    
    CGFloat titleX = CGRectGetMaxX(self.moreButton.frame) + 8;
    CGSize titleSize = [self.titleLabel sizeThatFits:CGSizeMake(self.view.bounds.size.width - titleX - 20, MAXFLOAT)];
    self.titleLabel.frame = CGRectMake(titleX, 0, self.view.bounds.size.width - titleX - 20, titleSize.height);
    self.titleLabel.center = CGPointMake(self.titleLabel.center.x, self.moreButton.center.y);
    
    CGSize greenLabelSize = [self.greenLabel sizeThatFits:CGSizeMake(self.view.bounds.size.width - titleX - 20, MAXFLOAT)];
    self.greenLabel.frame = CGRectMake(titleX, CGRectGetMaxY(self.moreButton.frame) + 12, self.view.bounds.size.width - titleX - 20, greenLabelSize.height);
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
    
    self.otherButton.frame = CGRectMake(self.redImageView.frame.origin.x, CGRectGetMaxY(self.redLabel.frame) + 20, self.view.bounds.size.width - self.redImageView.frame.origin.x * 2, 44);
    
    CGSize otherLabelSize = [self.otherLabel sizeThatFits:CGSizeMake(self.otherButton.frame.size.width - 44, MAXFLOAT)];
    self.otherLabel.frame = CGRectMake(self.otherButton.frame.origin.x + 22, CGRectGetMaxY(self.otherButton.frame) + 12, self.otherButton.frame.size.width - 44, otherLabelSize.height);
    
    self.backgroundView.frame = self.view.bounds;
}

- (void)handleAdditionalStrings:(UIButton *)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Additional Localisations" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (NSString *string in [TSCLocalisationController sharedController].additionalLocalisedStrings) {
        
        [alert addAction:[UIAlertAction actionWithTitle:string style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [self presentLocalisationEditViewControllerWithLocalisation:string];
        }]];
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)presentLocalisationEditViewControllerWithLocalisation:(NSString *)localisedString
{
    
    Localisation *localisation = [[TSCLocalisationController sharedController] CMSLocalisationForLocalisationKey:localisedString.localisationKey];
    
    __block TSCLocalisationEditViewController *editViewController;
    if (localisation) {
        
        editViewController = [[TSCLocalisationEditViewController alloc] initWithLocalisation:localisation];
        
    } else {
		
		editViewController = [[TSCLocalisationEditViewController alloc] initWithKey:localisedString.localisationKey];
    }
    
    if (editViewController) {
        
        editViewController.delegate = self;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:editViewController];
        [self presentViewController:navController animated:true completion:nil];
    }
}

- (void)handleDismiss
{
    
    CAKeyframeAnimation *quarterTurn = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    quarterTurn.values = @[@(DegreesToRadians(45)),@(DegreesToRadians(0))];
    quarterTurn.duration = 0.4;
    quarterTurn.fillMode = kCAFillModeForwards;
    quarterTurn.removedOnCompletion = false;
    quarterTurn.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.moreButton.layer addAnimation:quarterTurn forKey:@"anim"];
    
    [UIView animateWithDuration:0.2 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.greenImageView.transform = CGAffineTransformMakeTranslation(0, self.moreButton.center.y - self.greenImageView.center.y);
        
    } completion:nil];
    
    [UIView animateWithDuration:0.2 delay:0.05 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.amberImageView.transform = CGAffineTransformMakeTranslation(0, self.moreButton.center.y - self.amberImageView.center.y);
        
    } completion:nil];
    
    [UIView animateWithDuration:0.2 delay:0.1 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.redImageView.transform = CGAffineTransformMakeTranslation(0, self.moreButton.center.y - self.redImageView.center.y);
        
    } completion:nil];
    
    [UIView animateWithDuration:0.9 delay:0.1 usingSpringWithDamping:1.0 initialSpringVelocity:0 options:kNilOptions animations:^{
        
        self.backgroundView.alpha = 0.0;
        self.containerView.alpha = 0.0;
        self.otherButton.alpha = 0.0;

    } completion:^(BOOL complete){
        
        if (complete) {
            if (self.TSCLocalisationDismissHandler) {
                self.TSCLocalisationDismissHandler();
            }
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.viewHasAppeared) {
        return;
    }
    
    CAKeyframeAnimation *quarterTurn = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    quarterTurn.values = @[@(0),@(DegreesToRadians(140)),@(DegreesToRadians(225))];
    quarterTurn.duration = 0.6;
    quarterTurn.fillMode = kCAFillModeForwards;
    quarterTurn.removedOnCompletion = false;
    quarterTurn.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [self.moreButton.layer addAnimation:quarterTurn forKey:@"anim"];
    
    if ([[TSCLocalisationController sharedController] additionalLocalisedStrings] == nil || [[TSCLocalisationController sharedController] additionalLocalisedStrings].count == 0) {
        self.otherButton.userInteractionEnabled = false;
    }
    
    [UIView animateWithDuration:0.8 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0 options:kNilOptions animations:^{
        
        self.containerView.alpha = 1.0;
        self.backgroundView.alpha = 1.0;
        if ([[TSCLocalisationController sharedController] additionalLocalisedStrings] == nil || [[TSCLocalisationController sharedController] additionalLocalisedStrings].count == 0) {
            self.otherButton.alpha = 0.2;
        } else {
            self.otherButton.alpha = 1.0;
        }
        
    } completion:nil];
    
    self.greenImageView.transform = CGAffineTransformMakeTranslation(0, self.moreButton.center.y - self.greenImageView.center.y);
    self.amberImageView.transform = CGAffineTransformMakeTranslation(0, self.moreButton.center.y - self.amberImageView.center.y);
    self.redImageView.transform = CGAffineTransformMakeTranslation(0, self.moreButton.center.y - self.redImageView.center.y);
    
    self.greenImageView.alpha = 1.0;
    self.amberImageView.alpha = 1.0;
    self.redImageView.alpha = 1.0;
    
    [UIView animateWithDuration:0.3 delay:0.1 usingSpringWithDamping:0.8 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.redImageView.transform = CGAffineTransformIdentity;
        
    } completion:nil];
    
    [UIView animateWithDuration:0.3 delay:0.2 usingSpringWithDamping:0.8 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.amberImageView.transform = CGAffineTransformIdentity;
        
    } completion:nil];
    
    [UIView animateWithDuration:0.3 delay:0.3 usingSpringWithDamping:0.8 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.greenImageView.transform = CGAffineTransformIdentity;
        
    } completion:nil];
    
    self.viewHasAppeared = true;
}

- (void)editingCancelledIn:(TSCLocalisationEditViewController * _Nonnull)viewController {
	
}

- (void)editingSavedIn:(TSCLocalisationEditViewController * _Nullable)viewController {
	if ([[TSCLocalisationController sharedController] respondsToSelector:@selector(editingSavedIn:)]) {
		[[TSCLocalisationController sharedController] performSelector:@selector(editingSavedIn:) withObject:nil];
	}
}

@end
