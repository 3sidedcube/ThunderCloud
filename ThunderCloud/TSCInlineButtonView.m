//
//  TSCButtonView.m
//  ThunderStorm
//
//  Created by Andrew Hart on 12/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCInlineButtonView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor-Expanded.h"
#import "TSCLink.h"
@import ThunderTable;

#define BORDER_COLOR [[TSCThemeManager sharedTheme] mainColor]

@interface TSCInlineButtonView ()

@property (nonatomic, strong) UIImageView *iconView;

@end

@implementation TSCInlineButtonView

- (id)init
{
    self = [super init];
    
    if (self) {
        
        self.layer.borderWidth = 1;
        self.layer.cornerRadius = 8;
        self.backgroundColor = [UIColor whiteColor];
        
        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
        self.iconView.contentMode = UIViewContentModeCenter;
        [self addSubview:self.iconView];
        
        self.titleLabel.textColor = [[TSCThemeManager sharedTheme] mainColor];
        [self setTitleColor:[[TSCThemeManager sharedTheme] mainColor] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addTarget:self action:@selector(resetAppearanceToPressedDown) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
        [self addTarget:self action:@selector(resetAppearanceToUnpressed) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel | UIControlEventTouchDragExit];
        [self addTarget:self action:@selector(_TSCHandleTap) forControlEvents:UIControlEventTouchUpInside];
        
        [self resetAppearanceToUnpressed];
    }
    
    return self;
}

- (void)layoutSubviews
{
    self.iconView.frame = CGRectMake(12, 0, self.iconView.frame.size.width, self.iconView.frame.size.height);
    self.iconView.center = CGPointMake(self.iconView.center.x, self.frame.size.height / 2);
    self.titleLabel.frame = self.bounds;
}

- (void)resetAppearanceToPressedDown
{
    if (self.disabled) {
        [self resetAppearanceToUnpressed];
    } else {
        self.backgroundColor = [[TSCThemeManager sharedTheme] mainColor];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.layer.borderColor = BORDER_COLOR.CGColor;
    }
}

- (void)_TSCHandleTap
{
    if (!self.disabled) {
        [self.interactionDelegate inlineButtonWasTapped:self];
    } else {
        if (self.buttonDisabledReason == ButtonDisabledReasonCallsNotSupported) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SMS not supported"
                                                            message:@"SMS is not supported on this device"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

- (void)resetAppearanceToUnpressed
{
    if (!self.disabled) {
        self.titleLabel.alpha = 1.0;
        self.layer.borderColor = BORDER_COLOR.CGColor;
    } else {
        self.titleLabel.alpha = 0.3;
        self.layer.borderColor = [UIColor colorWithRed:BORDER_COLOR.red green:BORDER_COLOR.green blue:BORDER_COLOR.blue alpha:0.3].CGColor;
    }
    self.titleLabel.textColor = [[TSCThemeManager sharedTheme] mainColor];
    self.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Setter methods

- (void)setButton:(TSCInlineButton *)button
{
    _button = button;
    
    self.iconView.image = button.icon;
    self.titleLabel.text = button.title;
    
    //Pre-warning - this is ridiculous
    
    if ((self.button.link.url == nil || [[self.button.link.url absoluteString] isEqualToString:@""]) && !(self.button.link.recipients.count > 0) && ![self.button.link.linkClass isEqualToString:@"EmergencyLink"] && ![self.button.link.linkClass isEqualToString:@"TimerLink"]) {
        self.disabled = YES;
        self.buttonDisabledReason = ButtonDisabledReasonOther;
        //self.userInteractionEnabled = NO;
    } else {
        
        BOOL canMakeCalls = [[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"tel:1234567"]];
        
        if (!canMakeCalls &&
            ([self.button.link.linkClass isEqualToString:@"EmergencyLink"] ||
             [self.button.link.url.scheme isEqualToString:@"tel"] ||
             [self.button.link.linkClass isEqualToString:@"SmsLink"])) {
                self.disabled = YES;
                self.buttonDisabledReason = ButtonDisabledReasonCallsNotSupported;
            } else {
            self.disabled = NO;
        }
    }
    
    [self resetAppearanceToUnpressed];
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    [super setUserInteractionEnabled:userInteractionEnabled];
    
    [self resetAppearanceToUnpressed];
}

@end