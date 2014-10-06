//
//  TSCSplitViewController.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 18/12/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSCSplitViewController : UISplitViewController <UISplitViewControllerDelegate>

+ (TSCSplitViewController *)sharedController;
- (void)setLeftViewController:(id)viewController;
- (void)setRightViewController:(id)viewController fromNavigationController:(UINavigationController *)navController;
- (void)pushLeftViewController:(UIViewController *)viewController;
- (void)pushRightViewController:(UIViewController *)viewController;
- (void)presentFullScreenViewController:(UIViewController *)viewController animated:(BOOL)animated dismissPopover:(BOOL)dismissPopover;
- (void)presentFullScreenViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (BOOL)retainKeyAlreadyStored:(NSString *)retainKey;
- (void)setRightViewControllerUsingRetainKey:(NSString *)retainKey;
- (void)setRightViewController:(id)viewController fromNavigationController:(UINavigationController *)navController usingRetainKey:(NSString *)retainKey;
- (void)resetSharedController;

@property (nonatomic, strong) UIBarButtonItem *menuButton;

@end
