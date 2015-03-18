//
//  TSCStormLoginViewController.m
//  ThunderCloud
//
//  Created by Simon Mitchell on 18/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

#import "TSCStormLoginViewController.h"
#import "UIColor-Expanded.h"
#import "TSCTextField.h"
#import "TSCAuthenticationController.h"

@import ThunderTable;

@interface TSCStormLoginViewController()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *explanationLabel;

@property (nonatomic, strong) TSCTextField *usernameField;
@property (nonatomic, strong) TSCTextField *passwordField;

@property (nonatomic, strong) UIButton *loginButton;

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *containerView;

@end

@implementation TSCStormLoginViewController

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
    
    self.backgroundView.alpha = 0.0;
    [self.view addSubview:self.backgroundView];
    
    self.containerView = [UIView new];
    self.containerView.backgroundColor = [UIColor whiteColor];
    self.containerView.layer.cornerRadius = 4;
    self.containerView.alpha = 0.0;
    [self.view addSubview:self.containerView];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.titleLabel = [UILabel new];
    self.titleLabel.text = @"Login";
    self.titleLabel.font = [[TSCThemeManager sharedTheme] lightFontOfSize:22];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.containerView addSubview:self.titleLabel];
    
    self.explanationLabel = [UILabel new];
    self.explanationLabel.text = @"Log in to your Storm account to start editing Localisations";
    self.explanationLabel.textColor = [UIColor colorWithHexString:@"818181"];
    self.explanationLabel.font = [[TSCThemeManager sharedTheme] lightFontOfSize:14];
    self.explanationLabel.numberOfLines = 0;
    self.explanationLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.explanationLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.containerView addSubview:self.explanationLabel];
    
    self.usernameField = [TSCTextField new];
    self.usernameField.placeholder = @"Username";
    self.usernameField.layer.borderColor = [UIColor colorWithHexString:@"3892DF"].CGColor;
    self.usernameField.layer.borderWidth = 0.5;
    self.usernameField.layer.cornerRadius = 4.0;
    
    [self.containerView addSubview:self.usernameField];
    
    self.passwordField = [TSCTextField new];
    self.passwordField.placeholder = @"Password";
    self.passwordField.layer.borderColor = [UIColor colorWithHexString:@"3892DF"].CGColor;
    self.passwordField.layer.borderWidth = 0.5;
    self.passwordField.layer.cornerRadius = 4.0;
    self.passwordField.secureTextEntry = true;
    
    [self.containerView addSubview:self.passwordField];
    
    self.loginButton = [UIButton new];
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.loginButton setTitle:@"Log in" forState:UIControlStateNormal];
    self.loginButton.layer.backgroundColor = [UIColor colorWithHexString:@"3892DF"].CGColor;
    self.loginButton.layer.cornerRadius = 4;
    [self.loginButton addTarget:self action:@selector(handleLogin:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.containerView addSubview:self.loginButton];
    
    UITapGestureRecognizer *dismissGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDismissTap:)];
    [self.backgroundView addGestureRecognizer:dismissGesture];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.containerView.frame = CGRectMake(0, 0, 228, 269);
    self.containerView.center = self.view.center;
    
    self.titleLabel.frame = CGRectMake(0, 20, self.containerView.frame.size.width, 28);
    
    CGSize explanationSize = [self.explanationLabel sizeThatFits:CGSizeMake(self.containerView.frame.size.width - 40, MAXFLOAT)];
    self.explanationLabel.frame = CGRectMake(20, CGRectGetMaxY(self.titleLabel.frame) + 16, self.containerView.frame.size.width - 40, explanationSize.height);
    
    self.usernameField.frame = CGRectMake(20, CGRectGetMaxY(self.explanationLabel.frame) + 18, self.containerView.frame.size.width - 40, 36);
    self.passwordField.frame = CGRectMake(20, CGRectGetMaxY(self.usernameField.frame) + 8, self.containerView.frame.size.width - 40, 36);
    
    self.loginButton.frame = CGRectMake(20, CGRectGetMaxY(self.passwordField.frame) + 16, self.containerView.frame.size.width - 40, 36);
    
    self.backgroundView.frame = self.view.bounds;
}

- (void)handleLogin:(UIButton *)sender
{
    __weak typeof(self) welf = self;
    self.loginButton.enabled = false;
    self.loginButton.alpha = 0.5;
    
    [[TSCAuthenticationController sharedInstance] authenticateUsername:self.usernameField.text password:self.passwordField.text completion:^(BOOL sucessful, NSError *error) {
        
        if (welf) {
            
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
    [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0 options:kNilOptions animations:^{
        
        self.backgroundView.alpha = 0.0;
        self.containerView.alpha = 0.0;
        
    } completion:^(BOOL complete){
    
        if (complete) {
            if (self.completion) {
                self.completion(false, true);
            }
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0 options:kNilOptions animations:^{
        
        self.backgroundView.alpha = 1.0;
        self.containerView.alpha = 1.0;
    } completion:nil];
}

@end
