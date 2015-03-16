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
#import "TSCDeveloperController.h"
#import "TSCImage.h"
#import "TSCStormViewController.h"
#import "UIColor-Expanded.h"
#import "TSCSplitViewController.h"
#import "TSCStormObject.h"
@import ThunderBasics;
@import ThunderTable;

@interface TSCAccordionTabBarViewController () <TSCAccordionTabBarItemDelegate, UICollisionBehaviorDelegate>

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIViewController *previouslySelectedViewController;
@property (nonatomic, strong) NSMutableArray *viewControllersShouldDisplayNavigationBar;
@property (nonatomic, strong) UIView *placeholderNavigationView;

@end

@implementation TSCAccordionTabBarViewController

- (void)dealloc
{
    [_selectedViewController removeObserver:self forKeyPath:@"visibleViewController.navigationItem.titleView"];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject
{
    if (self = [super init]) {
        
        self.viewControllers = [[NSMutableArray alloc] init];
        self.placeholders = [[NSMutableArray alloc] init];
        self.viewControllersShouldDisplayNavigationBar = [[NSMutableArray alloc] init];
        
        for (NSDictionary *tabBarItemDictionary in dictionary[@"pages"]) {
            
            if ([tabBarItemDictionary[@"type"] isEqualToString:@"TabbedPageCollection"]) {
                NSMutableDictionary *typeDictionary = [NSMutableDictionary dictionaryWithDictionary:tabBarItemDictionary];
                [typeDictionary setValue:@"NavigationTabBarViewController" forKey:@"type"];
                
                TSCNavigationTabBarViewController *navTabController = [[TSCNavigationTabBarViewController alloc] initWithDictionary:typeDictionary];
                navTabController.title = TSCLanguageDictionary(tabBarItemDictionary[@"tabBarItem"][@"title"]);
                navTabController.tabBarItem.image = [TSCImage imageWithDictionary:tabBarItemDictionary[@"tabBarItem"][@"image"]];
                
                [self.viewControllers addObject:navTabController];
                [self.viewControllersShouldDisplayNavigationBar addObject:[NSNumber numberWithBool:NO]];
            } else {
                
                NSURL *pageURL = [NSURL URLWithString:tabBarItemDictionary[@"src"]];
                
                TSCStormViewController *viewController = [[TSCStormViewController alloc] initWithURL:pageURL];
                viewController.tabBarItem.title = TSCLanguageDictionary(tabBarItemDictionary[@"tabBarItem"][@"title"]);
                viewController.tabBarItem.image = [TSCImage imageWithDictionary:tabBarItemDictionary[@"tabBarItem"][@"image"]];
                
                TSCPlaceholder *placeholder = [[TSCPlaceholder alloc] initWithDictionary:tabBarItemDictionary[@"tabBarItem"]];
                [self.placeholders addObject:placeholder];
                
                if (viewController) {
                    
                    [self.viewControllers addObject:viewController];
                    [self.viewControllersShouldDisplayNavigationBar addObject:[NSNumber numberWithBool:NO]];
                }
            }
        }
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        self.viewControllers = [[NSMutableArray alloc] init];
        self.placeholders = [[NSMutableArray alloc] init];
        self.viewControllersShouldDisplayNavigationBar = [[NSMutableArray alloc] init];
        
        for (NSDictionary *tabBarItemDictionary in dictionary[@"pages"]) {
            
            if ([tabBarItemDictionary[@"type"] isEqualToString:@"TabbedPageCollection"]) {
                NSMutableDictionary *typeDictionary = [NSMutableDictionary dictionaryWithDictionary:tabBarItemDictionary];
                [typeDictionary setValue:@"NavigationTabBarViewController" forKey:@"type"];
                
                TSCNavigationTabBarViewController *navTabController = [[TSCNavigationTabBarViewController alloc] initWithDictionary:typeDictionary];
                navTabController.title = TSCLanguageDictionary(tabBarItemDictionary[@"tabBarItem"][@"title"]);
                navTabController.tabBarItem.image = [TSCImage imageWithDictionary:tabBarItemDictionary[@"tabBarItem"][@"image"]];
                
                [self.viewControllers addObject:navTabController];
                [self.viewControllersShouldDisplayNavigationBar addObject:[NSNumber numberWithBool:NO]];
            } else {
                
                NSURL *pageURL = [NSURL URLWithString:tabBarItemDictionary[@"src"]];
                
                TSCStormViewController *viewController = [[TSCStormViewController alloc] initWithURL:pageURL];
                viewController.tabBarItem.title = TSCLanguageDictionary(tabBarItemDictionary[@"tabBarItem"][@"title"]);
                viewController.tabBarItem.image = [TSCImage imageWithDictionary:tabBarItemDictionary[@"tabBarItem"][@"image"]];
                
                TSCPlaceholder *placeholder = [[TSCPlaceholder alloc] initWithDictionary:tabBarItemDictionary[@"tabBarItem"]];
                [self.placeholders addObject:placeholder];
                
                if (viewController) {
                    
                    [self.viewControllers addObject:viewController];
                    [self.viewControllersShouldDisplayNavigationBar addObject:[NSNumber numberWithBool:NO]];
                }
            }
        }
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (isPad()) {
        
        self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        self.placeholderNavigationView = [UIView new];
        self.placeholderNavigationView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        UINavigationBar *placeholderNavBar = [[UINavigationBar alloc] initWithFrame:CGRectZero];
        
        [self.placeholderNavigationView addSubview:placeholderNavBar];
        [self.view addSubview:self.placeholderNavigationView];
    }
    
    self.accordionTabBarItems = [[NSMutableArray alloc] init];
    
    for (UIViewController *viewController in self.viewControllers) {
        
        TSCAccordionTabBarItem *item = [[TSCAccordionTabBarItem alloc] initWithTitle:viewController.tabBarItem.title image:viewController.tabBarItem.image tag:viewController.tabBarItem.tag];
        item.delegate = self;
        item.contentView = viewController.navigationItem.titleView;
        NSLog(@"Extra Button title: %@", viewController.navigationItem.leftBarButtonItem.title);
        [item.extraButton setTitle:viewController.navigationItem.leftBarButtonItem.title forState:UIControlStateNormal];
        [item.extraButton addTarget:viewController.navigationItem.leftBarButtonItem.target action:viewController.navigationItem.leftBarButtonItem.action forControlEvents:UIControlEventTouchUpInside];
        item.extraButton.userInteractionEnabled = YES;
        
        [self.accordionTabBarItems addObject:item];
    }
    
    self.view.backgroundColor = [[TSCThemeManager sharedTheme] mainColor];
    
    TSCAccordionTabBarItem *firstItem = self.accordionTabBarItems[0];
    if (firstItem) {
        firstItem.isFirstItem = true;
    }
    
    self.selectedTabIndex = 0;
    
    [self showPlaceholderViewController];
}

- (void)hello
{
    NSLog(@"hello");
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
    
    if (isPad()) {
        [self.view sendSubviewToBack:self.placeholderNavigationView];
    }
    [self layoutAccordionAnimated:NO];
    
    [self showPlaceholderViewController];
}

- (void)layoutAccordionAnimated:(BOOL)animated
{
    float y = 0;
    
    if ([TSCThemeManager isOS7]) {
        y = 20;
    }
    
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

- (void)showPlaceholderViewController
{
    if (isPad) {
        NSString *retainKey = [NSString stringWithFormat:@"%li", (long)self.selectedTabIndex];
        
        if ([[TSCSplitViewController sharedController] retainKeyAlreadyStored:retainKey]) {
            [[TSCSplitViewController sharedController] setRightViewControllerUsingRetainKey:retainKey];
        } else {
            TSCPlaceholder *placeholder = [self.placeholders objectAtIndex:self.selectedTabIndex];
            
            TSCPlaceholderViewController *placeholderVC = [[TSCPlaceholderViewController alloc] init];
            placeholderVC.title = placeholder.title;
            placeholderVC.placeholderDescription = placeholder.placeholderDescription;
            placeholderVC.image = placeholder.image;
            [[TSCSplitViewController sharedController] setRightViewController:placeholderVC fromNavigationController:self.navigationController usingRetainKey:retainKey];
        }
    }
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
        
        [self showPlaceholderViewController];
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
        
        if ([TSCThemeManager isOS7]) {
            [navController.navigationBar setBarTintColor:[[TSCThemeManager sharedTheme] mainColor]];
        } else {
            [navController.navigationBar setTintColor:[[TSCThemeManager sharedTheme] mainColor]];
            [navController.navigationBar setOpaque:YES];
        }
        
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