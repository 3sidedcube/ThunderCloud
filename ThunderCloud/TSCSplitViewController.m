//
//  TSCSplitViewController.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 18/12/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCSplitViewController.h"
#import "TSCDummyViewController.h"
#import "TSCTabbedPageCollection.h"
#import "TSCAccordionTabBarViewController.h"
#import "NSString+LocalisedString.h"
#import "TSCStormObject.h"
#import "TSCPlaceholderViewController.h"

@import ThunderBasics;
@import ThunderTable;

@interface TSCSplitViewController ()

@property (nonatomic, strong) UIView *spacingBackground;

@property (nonatomic, copy) NSString *previousRetainKey;
@property (nonatomic, strong) NSMutableDictionary *retainedViewControllers;

@property (retain, nonatomic) UIPopoverController *aPopoverController;

@end

@implementation TSCSplitViewController

static TSCSplitViewController *sharedController = nil;

+ (TSCSplitViewController *)sharedController
{
    @synchronized(self) {
        
        if (sharedController == nil) {
            sharedController = [[self alloc] init];
        }
    }
    
    return sharedController;
}

- (instancetype)init
{
    if (self = [super init]) {
        
        self.retainedViewControllers = [[NSMutableDictionary alloc] init];
        
        Class placholderDetailVCClass = [TSCStormObject classForClassKey:NSStringFromClass([TSCDummyViewController class])];
        
        self.primaryViewController = [self navigationControllerForViewController:[[placholderDetailVCClass alloc] init]];
        self.detailViewController = [self navigationControllerForViewController:[[placholderDetailVCClass alloc] init]];
        
        self.view.backgroundColor = [UIColor blackColor];
        self.spacingBackground = [[UIView alloc] init];
        self.spacingBackground.backgroundColor = [UIColor blackColor];
        [self.view addSubview:self.spacingBackground];
    }
    
    return self;
}

- (void)resetSharedController
{
    sharedController = nil;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.spacingBackground.frame = self.view.bounds;
    [self.view bringSubviewToFront:((UIViewController *)self.primaryViewController).view];
    [self.view bringSubviewToFront:((UIViewController *)self.detailViewController).view];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.spacingBackground.frame = self.view.bounds;
    
    [self.menuButton.target performSelector:self.menuButton.action withObject:self.menuButton afterDelay:0.01];
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    if (viewControllers.count > 0) {
        [self setLeftViewController:viewControllers[0]];
    }
    
    if (viewControllers.count > 1) {
        [self setRightViewController:viewControllers[1] fromNavigationController:nil];
    }
    
    [super setViewControllers:@[self.primaryViewController, self.detailViewController]];
}

- (void)setLeftViewController:(id)viewController
{
    self.primaryViewController = [self navigationControllerForViewController:viewController];
    [super setViewControllers:@[self.primaryViewController, self.detailViewController]];
}

- (void)setDetailViewController:(id)detailViewController
{
    if (detailViewController) {
        [super setViewControllers:@[self.primaryViewController,detailViewController]];
    }
    _detailViewController = detailViewController;
}

- (BOOL)retainKeyAlreadyStored:(NSString *)retainKey
{
    if ([self.retainedViewControllers objectForKey:retainKey]) {
        return YES;
    }
    
    return NO;
}

- (void)setRightViewControllerUsingRetainKey:(NSString *)retainKey
{
    if (self.previousRetainKey) {
        [self.retainedViewControllers setObject:self.detailViewController forKey:self.previousRetainKey];
    }
    
    if ([self.retainedViewControllers objectForKey:retainKey] && self.detailViewController != [self.retainedViewControllers objectForKey:retainKey]) {
        
        UIViewController *detailVC = [self.retainedViewControllers objectForKey:retainKey];
        self.detailViewController = detailVC;
    }
    
    if (self.menuButton) {
        ((UIViewController *)((UINavigationController *)self.detailViewController).viewControllers[0]).navigationItem.leftBarButtonItem = self.menuButton;
    }
    
    self.previousRetainKey = retainKey;
    
    [self.retainedViewControllers setObject:self.detailViewController forKey:self.previousRetainKey];
}

- (void)setRightViewController:(id)viewController fromNavigationController:(UINavigationController *)navController usingRetainKey:(NSString *)retainKey
{
    if (self.previousRetainKey) {
        [self.retainedViewControllers setObject:self.detailViewController forKey:self.previousRetainKey];
    }
    
    [self setRightViewController:viewController fromNavigationController:navController];
    
    self.previousRetainKey = retainKey;
    
    [self.retainedViewControllers setObject:self.detailViewController forKey:self.previousRetainKey];
}

- (void)setRightViewController:(id)viewController fromNavigationController:(UINavigationController *)navController
{
    if ([self.detailViewController isKindOfClass:[TSCDummyViewController class]] || navController.tabBarController == self.primaryViewController || navController == self.primaryViewController || [navController.parentViewController isKindOfClass:[TSCAccordionTabBarViewController class]] || [viewController isKindOfClass:[TSCPlaceholderViewController class]]) {
        self.detailViewController = [self navigationControllerForViewController:viewController];
        
        if (self.menuButton) {
            ((UIViewController *)((UINavigationController *)self.detailViewController).viewControllers[0]).navigationItem.leftBarButtonItem = self.menuButton;
        }
    } else {
        [self.detailViewController pushViewController:viewController animated:YES];
    }
    
    if ([navController.parentViewController isKindOfClass:[TSCAccordionTabBarViewController class]]) {
        [self.aPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)presentFullScreenViewController:(UIViewController *)viewController animated:(BOOL)animated dismissPopover:(BOOL)dismissPopover {
    
    [self presentViewController:viewController animated:animated completion:nil];
    
    if (dismissPopover) {
        [self.aPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)presentFullScreenViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self presentFullScreenViewController:viewController animated:animated dismissPopover:NO];
}

- (void)pushLeftViewController:(UIViewController *)viewController
{
    self.primaryViewController = [self navigationControllerForViewController:viewController];
    [self.primaryViewController pushViewController:viewController animated:YES];
}

- (void)pushRightViewController:(UIViewController *)viewController
{
    [self.detailViewController pushViewController:viewController animated:YES];
}

- (UINavigationController *)navigationControllerForViewController:(id)viewController
{
    if ([viewController isKindOfClass:[UINavigationController class]] || [viewController isKindOfClass:[TSCTabbedPageCollection class]]) {
        return viewController;
        
    } else if ([viewController isKindOfClass:[UIViewController class]]) {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        
        return navController;
    }
    
    return nil;
}

- (void)setupMenuButton {
    ((UIViewController *)((UINavigationController *)self.detailViewController).viewControllers[0]).navigationItem.leftBarButtonItem = self.menuButton;
}

#pragma mark - Delegate
- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        return YES;
    } else {
        return NO;
    }
}

- (NSUInteger)splitViewControllerSupportedInterfaceOrientations:(UISplitViewController *)splitViewController;
{
    return UIInterfaceOrientationMaskAll;
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    [barButtonItem setBackgroundImage:[[UIImage imageNamed:@"new-back-arrow-button" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 12, 1, 1)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [barButtonItem setTitle:[NSString stringWithLocalisationKey:@"_BUTTON_MENU" fallbackString:@"Menu"]];
    [barButtonItem setTitlePositionAdjustment:UIOffsetMake(10, -2) forBarMetrics:UIBarMetricsDefault];
    
    self.menuButton = barButtonItem;
    [self setupMenuButton];
    self.aPopoverController = pc;
}

- (void)splitViewController:(UISplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController
{
    
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)button
{
    self.menuButton = nil;
    
    if ([((UINavigationController *)self.detailViewController) respondsToSelector:@selector(viewControllers)]) {
        ((UIViewController *)((UINavigationController *)self.detailViewController).viewControllers[0]).navigationItem.leftBarButtonItem = nil;
    }
    
    self.aPopoverController = nil;
}

@end
