//
//  RCAlertManagementHubViewController.m
//  American Red Cross Disaster
//
//  Created by Phillip Caudell on 29/08/2013.
//  Copyright (c) 2013 madebyphill.co.uk. All rights reserved.
//

#import "TSCNavigationTabBarViewController.h"
#import "TSCStormViewController.h"
#import "TSCContentController.h"
@import ThunderTable;

@interface TSCNavigationTabBarViewController ()

@end

@implementation TSCNavigationTabBarViewController

- (void)dealloc
{
    if (self.selectedViewController.navigationItem.rightBarButtonItem) {
        [self.selectedViewController.navigationItem addObserver:self forKeyPath:@"rightBarButtonItem" options:kNilOptions context:nil];
    }
    
    if (self.selectedViewController.navigationItem.leftBarButtonItem) {
        [self.selectedViewController.navigationItem addObserver:self forKeyPath:@"leftBarButtonItem" options:kNilOptions context:nil];
    }
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    
    if (self) {
        
        NSURL *pageURL = [NSURL URLWithString:dictionary[@"src"]];

        NSString *pagePath = [[TSCContentController sharedController] pathForCacheURL:pageURL];
        NSData *pageData = [NSData dataWithContentsOfFile:pagePath];
        NSDictionary *pageDictionary = [NSJSONSerialization JSONObjectWithData:pageData options:kNilOptions error:nil];

        
        NSMutableArray *viewcontrollers = [NSMutableArray array];
        
        for (NSDictionary *page in pageDictionary[@"pages"]) {
            
            NSURL *pageURL = [NSURL URLWithString:page[@"src"]];
            
            TSCStormViewController *viewController = [[TSCStormViewController alloc] initWithURL:pageURL];
            
            if(viewController){
                [viewcontrollers addObject:viewController];
            }
            
        }
        
        self.viewControllers = viewcontrollers;
        
    }
    
    return self;
}

- (id)initWithViewControllers:(NSArray *)viewControllers
{
    self = [super init];
    
    if (self) {
        
        self.viewControllers = viewControllers;
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.selectedIndex = 0;
    
    if ([TSCThemeManager isOS7]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (self.viewStyle == TSCNavigationTabBarViewStyleInsideNavigationBar) {
        self.selectedViewController.view.frame = self.view.bounds;
    } else {
        CGRect viewFrame = self.view.bounds;
        viewFrame.origin.y += 30;
        self.selectedViewController.view.frame = viewFrame;
    }
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    _viewControllers = viewControllers;
    self.segmentedView = [[UIView alloc] init];
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:[self TSC_titlesForViewControllers:viewControllers]];
    if (![TSCThemeManager isOS7]) self.segmentedControl.tintColor = [[TSCThemeManager sharedTheme] mainColor];
    [self.segmentedControl setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 120, 25)];
    //self.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [self.segmentedControl addTarget:self action:@selector(TSC_handleSelectedIndexChange:) forControlEvents:UIControlEventValueChanged];
    
    if (self.viewStyle == TSCNavigationTabBarViewStyleInsideNavigationBar) {
        self.navigationItem.titleView = self.segmentedControl;
    }
}

- (void)TSC_handleSelectedIndexChange:(UISegmentedControl *)sender
{
    self.selectedIndex = sender.selectedSegmentIndex;
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
    [self.selectedViewController willMoveToParentViewController:nil];
    [self.selectedViewController removeFromParentViewController];
    [self.selectedViewController.view removeFromSuperview];
    [self.selectedViewController didMoveToParentViewController:nil];
    
    if (self.selectedViewController.navigationItem.rightBarButtonItem) {
        [self.selectedViewController.navigationItem removeObserver:self forKeyPath:@"rightBarButtonItem"];
    }
    
    if (self.selectedViewController.navigationItem.leftBarButtonItem) {
        [self.selectedViewController.navigationItem removeObserver:self forKeyPath:@"leftBarButtonItem"];
    }

    _selectedIndex = [self.viewControllers indexOfObject:selectedViewController];
    _selectedViewController = selectedViewController;
    _segmentedControl.selectedSegmentIndex = [self.viewControllers indexOfObject:_selectedViewController];
    
    [self.selectedViewController willMoveToParentViewController:self];
    [self addChildViewController:self.selectedViewController];
    
    self.navigationItem.rightBarButtonItem = self.selectedViewController.navigationItem.rightBarButtonItem;
    self.navigationItem.leftBarButtonItem = self.selectedViewController.navigationItem.leftBarButtonItem;
    
    if (self.selectedViewController.navigationItem.rightBarButtonItem) {
        [self.selectedViewController.navigationItem addObserver:self forKeyPath:@"rightBarButtonItem" options:kNilOptions context:nil];
    }
    
    if (self.selectedViewController.navigationItem.leftBarButtonItem) {
        [self.selectedViewController.navigationItem addObserver:self forKeyPath:@"leftBarButtonItem" options:kNilOptions context:nil];
    }

    [self.view addSubview:self.selectedViewController.view];
    [self viewWillLayoutSubviews];
    [self.selectedViewController didMoveToParentViewController:self];
    
    if (self.viewStyle == TSCNavigationTabBarViewStyleBelowNavigationBar) {
        [self.segmentedView removeFromSuperview];
        [self.view addSubview:self.segmentedView];
        
        if ([TSCThemeManager isOS7]) {
            self.segmentedView.frame = CGRectMake(0, 64, self.view.bounds.size.width, 40);
        } else {
            self.segmentedView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 40);
        }
        
        self.segmentedControl.frame = CGRectMake(10, 5, self.view.bounds.size.width - 20, 30);
        [self.segmentedView addSubview:self.segmentedControl];
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    self.selectedViewController = self.viewControllers[selectedIndex];
}

- (NSArray *)TSC_titlesForViewControllers:(NSArray *)viewControllers
{
    NSMutableArray *viewControllerTitles = [NSMutableArray arrayWithCapacity:viewControllers.count];

    for (UIViewController *viewController in viewControllers) {

        if (viewController.title) {
            [viewControllerTitles addObject:viewController.title];
        } else {
            [viewControllerTitles addObject:@"No title"];
//            [NSException raise:@"View controller missing title" format:@"The view controller %@ doesn't have a title property set.", viewController];
        }
        
    }

    return viewControllerTitles;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (self.viewControllers.count > 0) {
        UIViewController *viewController = self.viewControllers[0];
        
        return viewController.preferredStatusBarStyle;
    }
    
    return UIStatusBarStyleDefault;
}

#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"leftBarButtonItem"]) {
        self.navigationItem.leftBarButtonItem = self.selectedViewController.navigationItem.leftBarButtonItem;
    }
    
    if ([keyPath isEqualToString:@"rightBarButtonItem"]) {
        self.navigationItem.rightBarButtonItem = self.selectedViewController.navigationItem.rightBarButtonItem;
    }
}

@end
