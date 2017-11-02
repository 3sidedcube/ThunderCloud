//
//  TSCAccordionTabBarViewController.m
//  ThunderStorm
//
//  Created by Andrew Hart on 20/12/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCAccordionTabBarViewController.h"
#import "TSCNavigationTabBarViewController.h"
#import "TSCPlaceholderViewController.h"
#import "TSCPlaceholder.h"
#import "ThunderCloud/ThunderCloud-Swift.h"
#import "TSCImage.h"
@import ThunderBasics;
@import ThunderTable;

@interface TSCAccordionTabBarViewController () <TSCAccordionTabBarItemDelegate, UICollisionBehaviorDelegate>

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIViewController *previouslySelectedViewController;
@property (nonatomic, strong) NSMutableArray *viewControllersShouldDisplayNavigationBar;

@property (nonatomic, strong) UIView *placeholderNavigationView;
@property (nonatomic, strong) NSMutableArray *placeholders;

@end

@implementation TSCAccordionTabBarViewController

- (void)dealloc
{
    [_selectedViewController removeObserver:self forKeyPath:@"visibleViewController.navigationItem.titleView"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.placeholderNavigationView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 44+20);
    
    for (UIView *view in self.placeholderNavigationView.subviews) {
        view.frame = self.placeholderNavigationView.bounds;
    }
    
    [self layoutAccordionAnimated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.view sendSubviewToBack:self.placeholderNavigationView];
    }
    [self layoutAccordionAnimated:NO];
}

- (void)layoutAccordionAnimated:(BOOL)animated
{
    float y = 20;
    
    float remainingHeightAfterDisplayingTabBarItems = self.view.frame.size.height - (self.accordionTabBarItems.count * ACCORDION_TAB_BAR_ITEM_HEIGHT) - y;
    BOOL topBorders = false;
    
    for (TSCAccordionTabBarItem *item in self.accordionTabBarItems) {
        item.userInteractionEnabled = YES;
        
        if (!item.superview) {
            [self.view addSubview:item];
        }
        
        item.showTopBorder = topBorders;
        if (item.selected) {
            self.selectedViewController.view.frame = CGRectMake(0, item.frame.origin.y + item.frame.size.height, self.view.frame.size.width, 0);
            topBorders = true;
        } else {
            topBorders = false;
        }
        
        if (!animated) {
            item.frame = CGRectMake(0, y, self.view.frame.size.width, ACCORDION_TAB_BAR_ITEM_HEIGHT);
            
            if (item.selected) {
                self.selectedViewController.view.frame = CGRectMake(0, y + ACCORDION_TAB_BAR_ITEM_HEIGHT, self.view.frame.size.width, remainingHeightAfterDisplayingTabBarItems);
            }
        } else {
            __block UIView *previousVCBackground;
            __block UIViewController *prevViewController = self.previouslySelectedViewController;
            
            [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                item.frame = CGRectMake(0, y, self.view.frame.size.width, ACCORDION_TAB_BAR_ITEM_HEIGHT);
                
                if (item.selected) {
                    self.selectedViewController.view.frame = CGRectMake(0, y + ACCORDION_TAB_BAR_ITEM_HEIGHT, self.view.frame.size.width, remainingHeightAfterDisplayingTabBarItems);
                }
                
                previousVCBackground = [[UIView alloc] initWithFrame:self.previouslySelectedViewController.view.frame];
                previousVCBackground.backgroundColor = [UIColor blackColor];
                [self.view addSubview:previousVCBackground];
                [self.view sendSubviewToBack:previousVCBackground];
                prevViewController.view.alpha = 0.4;
                
            } completion:^(BOOL finished) {
                
                if (item.selected) {
                    [prevViewController.view removeFromSuperview];
                    [prevViewController didMoveToParentViewController:nil];
                    [previousVCBackground removeFromSuperview];
                }
            }];
        }
        
        y = y + ACCORDION_TAB_BAR_ITEM_HEIGHT;
        
        if (item.selected) {
            y = y + remainingHeightAfterDisplayingTabBarItems;
        }
    }
    
    [self addChildViewController:self.selectedViewController];
    [self.view addSubview:self.selectedViewController.view];
    [self.selectedViewController didMoveToParentViewController:self];
    
    for (UIView *item in self.accordionTabBarItems) {
        [self.view bringSubviewToFront:item];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    UINavigationController *controller = object;
    [controller setNavigationBarHidden:NO];
    [self.viewControllersShouldDisplayNavigationBar replaceObjectAtIndex:self.selectedTabIndex withObject:[NSNumber numberWithBool:YES]];
}

#pragma mark - TSCAccordionTabBarItemDelegate methods

- (void)tabBarItemWasPressed:(TSCAccordionTabBarItem *)tabBarItem
{
    if (tabBarItem.selected == NO) {
        
        NSInteger index = [self.accordionTabBarItems indexOfObject:tabBarItem];
        self.selectedTabIndex = index;
        
        [self layoutAccordionAnimated:NO];
    }
}

#pragma mark - Setter methods

- (void)setSelectedTabIndex:(NSInteger)selectedTabIndex
{
    _selectedTabIndex = selectedTabIndex;
    
    if (self.viewControllers.count > selectedTabIndex) {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[self.viewControllers objectAtIndex:selectedTabIndex]];
        
        if (self.viewControllersShouldDisplayNavigationBar.count > selectedTabIndex && [[self.viewControllersShouldDisplayNavigationBar objectAtIndex:selectedTabIndex] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
            [navController setNavigationBarHidden:NO];
        } else {
            [navController setNavigationBarHidden:YES];
        }
        
        self.selectedViewController = navController;
        
        [navController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        
		[navController.navigationBar setBarTintColor:[TSCThemeManager sharedManager].theme.mainColor];
        
        [navController.navigationBar setTranslucent:NO];
        navController.navigationBar.frame = CGRectMake(0, 100, navController.navigationBar.frame.size.width, navController.navigationBar.frame.size.height);
    }
    
    if (self.accordionTabBarItems.count > selectedTabIndex) {
        
        for (TSCAccordionTabBarItem *item in self.accordionTabBarItems) {
            NSInteger index = [self.accordionTabBarItems indexOfObject:item];
            
            if (index == selectedTabIndex) {
                item.selected = YES;
            } else {
                item.selected = NO;
            }
        }
        
        TSCAccordionTabBarItem *item = [self.accordionTabBarItems objectAtIndex:selectedTabIndex];
        item.selected = YES;
    }
    
    [self layoutAccordionAnimated:self.isViewLoaded && self.view.window];
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
    if (self.previouslySelectedViewController) {
        [self.previouslySelectedViewController removeObserver:self forKeyPath:@"visibleViewController.navigationItem.titleView"];
    }
    
    self.previouslySelectedViewController = _selectedViewController;
    
    _selectedViewController = selectedViewController;
    [_selectedViewController addObserver:self forKeyPath:@"visibleViewController.navigationItem.titleView" options:0 context:NULL];
    
    return;
}

@end
