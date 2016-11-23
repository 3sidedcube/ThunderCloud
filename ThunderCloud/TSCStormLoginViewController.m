//
//  TSCStormLoginViewController.m
//  ThunderCloud
//
//  Created by Simon Mitchell on 18/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

#import "TSCStormLoginViewController.h"
#import "TSCAuthenticationController.h"

@import ThunderTable;
@import ThunderBasics;

@interface TSCStormLoginViewController()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *explanationLabel;

@property (nonatomic, weak) IBOutlet TSCTextField *usernameField;
@property (nonatomic, weak) IBOutlet TSCTextField *passwordField;

@property (nonatomic, weak) IBOutlet TSCButton *loginButton;

@property (nonatomic, weak) IBOutlet UIVisualEffectView *backgroundView;
@property (nonatomic, weak) IBOutlet UIView *containerView;

@property (nonatomic, assign) BOOL loggedIn;

@end

@implementation TSCStormLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.explanationLabel.text = self.reason ? self.reason : @"Log in to your Storm account to start editing Localisations";
    self.explanationLabel.textColor = [UIColor colorWithHexString:@"818181"];
    
  
    self.usernameField.borderWidth = (double)1/[[UIScreen mainScreen] scale];
    self.passwordField.borderWidth = (double)1/[[UIScreen mainScreen] scale];
    
    [self.loginButton addTarget:self action:@selector(handleLogin:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    UITapGestureRecognizer *dismissGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDismissTap:)];
    [self.backgroundView addGestureRecognizer:dismissGesture];
}

- (void)keyboardWillShow:(NSNotification *)aNotification {
    
    NSDictionary *userInfo = aNotification.userInfo;
    
    //
    // Get keyboard size.
    
    NSValue *endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardEndFrame = [self.view convertRect:endFrameValue.CGRectValue fromView:nil];
    
    //
    // Get keyboard animation.
    
    NSNumber *durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = durationValue.doubleValue;
    
    NSNumber *curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curveValue.intValue;
    
    CGFloat offset = 0;
    if (keyboardEndFrame.origin.y < CGRectGetMaxY(self.containerView.frame)) {
        offset = keyboardEndFrame.origin.y - CGRectGetMaxY(self.containerView.frame);
    }
        
    if (animationDuration != 0) {
        
        [UIView animateWithDuration:animationDuration
                              delay:0.0
                            options:(animationCurve << 16)
                         animations:^{
                             
                             self.containerView.transform = CGAffineTransformMakeTranslation(0, offset - 16);
                         }
                         completion:nil];
    }
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    NSDictionary *userInfo = aNotification.userInfo;
    
    //
    // Get keyboard animation.
    
    NSNumber *durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = durationValue.doubleValue;
    
    NSNumber *curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curveValue.intValue;
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:(animationCurve << 16)
                     animations:^{
                         
                         self.containerView.transform = CGAffineTransformIdentity;
                     }
                     completion:nil];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)handleLogin:(UIButton *)sender
{
    __weak typeof(self) welf = self;
    self.loginButton.enabled = false;
    self.loginButton.alpha = 0.5;
    
    [[TSCAuthenticationController sharedInstance] authenticateUsername:self.usernameField.text password:self.passwordField.text completion:^(BOOL sucessful, NSError *error) {
        
        if (welf) {
            
            welf.loggedIn = sucessful;
            if (!sucessful) {
                
                welf.usernameField.layer.borderColor = [UIColor colorWithHexString:@"FF3B39"].CGColor;
                welf.passwordField.layer.borderColor = [UIColor colorWithHexString:@"FF3B39"].CGColor;
            } else {
                
                welf.usernameField.layer.borderColor = [UIColor colorWithHexString:@"72D33B"].CGColor;
                welf.passwordField.layer.borderColor = [UIColor colorWithHexString:@"72D33B"].CGColor;
            }
            
            welf.loginButton.enabled = true;
            welf.loginButton.alpha = 1.0;
            
            [welf handleDismissTap:nil];

        }
    }];
}

- (void)handleDismissTap:(UITapGestureRecognizer *)tapGesture
{
    
    if (self.passwordField.isFirstResponder) {
        [self.passwordField resignFirstResponder];
    }
    
    if (self.usernameField.isFirstResponder) {
        [self.usernameField resignFirstResponder];
    }
    
    if (!self.loggedIn && !tapGesture) {
        
        self.completion(false, false);
        return;
    }
    
    if (self.loggedIn && !tapGesture && self.successViewController) {
        
        UIView *childView = self.successViewController.view;
        
        childView.alpha = 0.0;
        [self addChildViewController:self.successViewController];
        [self.containerView addSubview:childView];
        
        [self.backgroundView removeGestureRecognizer:self.backgroundView.gestureRecognizers.firstObject];
        
        // Remove translatesAutoresizingMaskIntoConstraints so we can constrain it to our container view
        childView.translatesAutoresizingMaskIntoConstraints = false;
        
        // Constrain the success view controller to our container view
        [NSLayoutConstraint activateConstraints:@[
            [childView.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor],
            [childView.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor],
            [childView.topAnchor constraintEqualToAnchor:self.containerView.topAnchor],
            [childView.bottomAnchor constraintEqualToAnchor:self.containerView.bottomAnchor],
        ]];
        
        [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0 options:kNilOptions animations:^{
            
            self.titleLabel.alpha = 0.0;
            self.explanationLabel.alpha = 0.0;
            self.passwordField.alpha = 0.0;
            self.usernameField.alpha = 0.0;
            self.loginButton.alpha = 0.0;
            
            [self.titleLabel removeFromSuperview];
            [self.explanationLabel removeFromSuperview];
            [self.passwordField removeFromSuperview];
            [self.usernameField removeFromSuperview];
            [self.loginButton removeFromSuperview];
            
            childView.alpha = 1.0;
            
        } completion:^(BOOL complete){
            
            if (complete) {
                
                if (self.completion) {
                    self.completion(self.loggedIn, !self.loggedIn);
                }
            }
        }];
        
    } else {
        
        [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0 options:kNilOptions animations:^{
            
            self.backgroundView.alpha = 0.0;
            self.containerView.alpha = 0.0;
            
        } completion:^(BOOL complete){
            
            if (complete) {
                if (self.completion) {
                    
                    self.completion(self.loggedIn, !self.loggedIn);
                }
            }
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0 options:kNilOptions animations:^{
        
        self.backgroundView.alpha = 1.0;
        self.containerView.alpha = 1.0;
    } completion:nil];
}

@end
