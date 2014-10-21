//
//  TSCHUDAlertController.m
//  ThunderStorm
//
//  Created by Andrew Hart on 19/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCHUDAlertController.h"
#import "CAGradientLayer+AutoGradient.h"
#import "UIView+Pop.h"
#import "UIImage+ImageEffects.h"
@import ThunderBasics;

#define ALERT_CONTROLLER_CUSTOM_VIEW_TOP_INSET 14
#define ALERT_CONTROLLER_ACTION_BUTTON_INSET 9
#define ALERT_CONTROLLER_ACTION_BUTTON_WIDTH (ALERT_CONTROLLER_WIDTH - (ALERT_CONTROLLER_ACTION_BUTTON_INSET * 2))

@interface TSCHUDAlertController ()

@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) UIView *customView;
@property (nonatomic, strong) NSArray *actionButtons;
@property (nonatomic) TSCAlertAdditionalButtonType additionalButtonType;
@property (nonatomic, strong) UIButton *dismissButton;
@property (nonatomic, strong) UIButton *additionalButton;
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIButton *backgroundDismissButton;

@end

@implementation TSCHUDAlertController

- (id)init
{
    self = [super init];
    
    if (self) {
        self.backgroundDismissButton = [[UIButton alloc] init];
        self.backgroundDismissButton.backgroundColor = [UIColor clearColor];
        self.backgroundDismissButton.adjustsImageWhenHighlighted = NO;
        [self.backgroundDismissButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

#pragma mark - Data collection methods

- (void)reloadData
{
    if (!self.view) {
        self.view = [[UIView alloc] init];
        self.view.backgroundColor = [UIColor whiteColor];
        self.view.layer.cornerRadius = 5;
    }
    
    self.customView = [self.dataSource customViewForAlertController:self];
    [self.view addSubview:self.customView];
    
    if ([self.delegate respondsToSelector:@selector(additionalButtonTypeForAlertController:)]) {
        self.additionalButtonType = [self.dataSource additionalButtonTypeForAlertController:self];
    } else {
        self.additionalButtonType = TSCAlertAdditionalButtonTypeNone;
    }
    
    if (self.additionalButtonType != TSCAlertAdditionalButtonTypeNone) {
        if (!self.additionalButton) {
            
            self.additionalButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.additionalButton.frame = CGRectMake(10, 10, 22, 30);
            self.additionalButton.contentMode = UIViewContentModeCenter;
            [self.view addSubview:self.additionalButton];
        }
        
        if (self.additionalButtonType == TSCAlertAdditionalButtonTypeShare) {
            [self.additionalButton setImage:[UIImage imageNamed:TSCLanguageString(@"_BUTTON_SHARE") ? TSCLanguageString(@"_BUTTON_SHARE") : @"Share"] forState:UIControlStateNormal];
        }
        
        [self.additionalButton addTarget:self action:@selector(handleAdditionalButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.additionalButton removeFromSuperview];
    }
    
    if (!self.dismissButton) {
        self.dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(ALERT_CONTROLLER_WIDTH - 10 - 30, 10, 30, 30)];
        [self.dismissButton setImage:[UIImage imageNamed:@"dismiss"] forState:UIControlStateNormal];
        [self.dismissButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if ([self.dataSource respondsToSelector:@selector(shouldDisplayDismissButtonInAlertController:)]) {
        if ([self.dataSource shouldDisplayDismissButtonInAlertController:self]) {
            [self.view addSubview:self.dismissButton];
        } else {
            [self.dismissButton removeFromSuperview];
        }
    } else {
        [self.view addSubview:self.dismissButton];
    }
    
    for (UIButton *button in self.actionButtons) {
        [button removeFromSuperview];
    }
    
    self.actionButtons = nil;
    
    NSMutableArray *actionButtons = [NSMutableArray new];
    
    int numberOfActionButtons = [self.dataSource numberOfActionButtonsForAlertController:self];
    int i = 0;
    
    while (i < numberOfActionButtons) {
        
        TSCHUDButton *button = [[TSCHUDButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [button setTitle:[self.dataSource alertController:self titleForActionButtonAtIndex:i] forState:UIControlStateNormal];
        button.hudButtonType = [self.dataSource alertController:self typeForActionButtonAtIndex:i];
        button.tag = i;
        [button addTarget:self action:@selector(handleActionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        
        [actionButtons addObject:button];
        i++;
    }
    
    self.actionButtons = actionButtons;
    
    [self layoutViews];
}

#pragma mark - Button methods

- (void)handleAdditionalButtonPressed
{
    if ([self.delegate respondsToSelector:@selector(additionalButtonWasTappedInAlertController:)]) {
        [self.delegate additionalButtonWasTappedInAlertController:self];
    }
}

- (void)handleActionButtonPressed:(UIButton *)button
{
    [self.delegate alertController:self buttonWasSelectedAtIndex:button.tag];
}

#pragma mark - Display methods

- (void)layoutViews
{
    self.customView.frame = CGRectMake(0, ALERT_CONTROLLER_CUSTOM_VIEW_TOP_INSET, self.customView.frame.size.width, self.customView.frame.size.height);
    self.customView.center = CGPointMake(ALERT_CONTROLLER_WIDTH / 2, self.customView.center.y);
    
    
    float viewHeight = self.customView.frame.size.height + (ALERT_CONTROLLER_CUSTOM_VIEW_TOP_INSET * 2);
    
    for (UIButton *button in self.actionButtons) {
        button.frame = CGRectMake(ALERT_CONTROLLER_ACTION_BUTTON_INSET, viewHeight, ALERT_CONTROLLER_ACTION_BUTTON_WIDTH, HUD_BUTTON_HEIGHT);
        
        viewHeight = viewHeight + HUD_BUTTON_HEIGHT + ALERT_CONTROLLER_ACTION_BUTTON_INSET;
    }
    
    self.view.frame = CGRectMake(0, 0, ALERT_CONTROLLER_WIDTH, viewHeight);
    
    self.backgroundDismissButton.frame = self.window.bounds;
}

- (void)show
{
    UIImage *background = [self screenshot];
    background = [background applyDarkEffect];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.windowLevel = UIWindowLevelNormal;
    self.window.backgroundColor = [UIColor clearColor];
    
    [self.window addSubview:self.backgroundDismissButton];
    
    [self reloadData];
    
    self.view.center = CGPointMake(CGRectGetMidX(self.window.bounds), CGRectGetMidY(self.window.bounds));
    
    [self.window addSubview:self.view];
    [self.window makeKeyAndVisible];
    
    [self.view popIn];
    
    [self.backgroundDismissButton setImage:background forState:UIControlStateNormal];
    
    self.backgroundDismissButton.alpha = 0;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundDismissButton.alpha = 1;
    }];
    
}

- (void)dismiss
{
    if ([self.delegate respondsToSelector:@selector(willDismissAlertController:)]) {
        [self.delegate willDismissAlertController:self];
    }
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.view.transform = CGAffineTransformMakeScale(0.1, 0.1);
        self.view.alpha = 0;
        self.backgroundDismissButton.alpha = 0;
    }completion:^(BOOL finished) {
        
        [self.backgroundDismissButton removeFromSuperview];
        self.backgroundDismissButton = nil;
        
        [self.view removeFromSuperview];
        self.view = nil;
        
        self.window.hidden = YES;
        [[[[UIApplication sharedApplication] windows] objectAtIndex:0] makeKeyAndVisible];
        self.window = nil;
        [self.window removeFromSuperview];
    }];
}

- (UIImage *)screenshot
{
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    
    if (NULL != UIGraphicsBeginImageContextWithOptions) {
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    } else {
//        UIGraphicsBeginImageContext(imageSize);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen]) {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context, -[window bounds].size.width *[[window layer] anchorPoint].x, -[window bounds].size.height *[[window layer] anchorPoint].y);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end
