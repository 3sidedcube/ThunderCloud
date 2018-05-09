//
//  TSCBadgeShareViewController.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 28/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <ThunderCloud/ThunderCloud-Swift.h>
#import "TSCBadgeShareViewController.h"
#import "TSCImage.h"
#import <ThunderCloud/ThunderCloud-Swift.h>

@import ThunderTable;
@import ThunderBasics;

@interface TSCBadgeShareViewController ()

@end

@implementation TSCBadgeShareViewController

- (instancetype)initWithBadge:(TSCBadge *)badge
{
    if (self = [super init]) {
        
        self.badge = badge;
        
        self.title = self.badge.title;
        
        Class achievementDisplayViewClass = [[TSCStormObjectFactory sharedFactory] classForClassKey:NSStringFromClass([TSCAchievementDisplayView class])];
        _achievementView = [[achievementDisplayViewClass alloc] initWithFrame:CGRectMake(0, 0, 275, 250) image:[TSCStormGenerator imageFromJSON:self.badge.icon] subtitle:@"You've earned this badge!"];
        [self.view addSubview:_achievementView];
        
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
            UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss:)];
            self.navigationItem.rightBarButtonItem = cancelButton;
        }
        
        UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStylePlain target:self action:@selector(share:)];
        self.navigationItem.leftBarButtonItem = shareButton;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"efeff4"];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (self.view.frame.size.width < 450) {
        _achievementView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width);
        
        self.achievementView.center = CGPointMake(self.view.bounds.size.width / 2, (self.view.frame.size.height / 2));
    } else {
        _achievementView.frame = CGRectMake(150, 150, self.view.frame.size.width - 300, self.view.frame.size.width - 300);
    }
}

#pragma mark - UIBarButtonItem actions

- (void)dismiss:(UIBarButtonItem *)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)share:(UIBarButtonItem *)button
{
    NSArray *sharables = @[self.badge.shareMessage, self.badge.icon];
    
    UIActivityViewController *shareViewController = [[UIActivityViewController alloc] initWithActivityItems:sharables applicationActivities:nil];
    shareViewController.excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll, UIActivityTypePrint, UIActivityTypeAssignToContact];
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [self presentViewController:shareViewController animated:YES completion:nil];
    }
}

- (BOOL)shouldAutorotate
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    }
    
    return UIInterfaceOrientationMaskPortrait;
}

@end
