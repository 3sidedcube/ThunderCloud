//
//  RCAlertManagementHubViewController.m
//  American Red Cross Disaster
//
//  Created by Phillip Caudell on 29/08/2013.
//  Copyright (c) 2013 madebyphill.co.uk. All rights reserved.
//

#import "TSCNavigationTabBarViewController.h"
#import "TSCStormViewController.h"
#import "ThunderCloud/ThunderCloud-Swift.h"
@import ThunderTable;

@interface TSCNavigationTabBarViewController ()

@property (nonatomic, assign) BOOL definesOwnLeftNavigationItems;
@property (nonatomic, assign) BOOL definesOwnRightNavigationItems;

@property (nonatomic, assign) BOOL observingRightBarItems;
@property (nonatomic, assign) BOOL observingLeftBarItems;

@end

@implementation TSCNavigationTabBarViewController

- (void)dealloc
{
    if (self.observingRightBarItems) {
        
        [self.selectedViewController.navigationItem removeObserver:self forKeyPath:@"rightBarButtonItems"];
        [self.selectedViewController.navigationItem removeObserver:self forKeyPath:@"rightBarButtonItem"];
    }

    if (self.observingLeftBarItems) {
        
        [self.selectedViewController.navigationItem removeObserver:self forKeyPath:@"leftBarButtonItems"];
        [self.selectedViewController.navigationItem removeObserver:self forKeyPath:@"leftBarButtonItem"];
    }
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        
        NSURL *pageURL = [NSURL URLWithString:dictionary[@"src"]];
        
        NSURL *_pageURL = [[TSCContentController shared] urlForCacheURL:pageURL];
        
        if (_pageURL) {
            
            NSData *pageData = [NSData dataWithContentsOfURL:_pageURL];
            NSDictionary *pageDictionary = [NSJSONSerialization JSONObjectWithData:pageData options:kNilOptions error:nil];
            
            NSMutableArray *viewcontrollers = [NSMutableArray array];
            
            for (NSDictionary *page in pageDictionary[@"pages"]) {
                
                NSURL *pageURL = [NSURL URLWithString:page[@"src"]];
                
                TSCStormViewController *viewController = [[TSCStormViewController alloc] initWithURL:pageURL];
                
                if (viewController) {
                    [viewcontrollers addObject:viewController];
                }
            }
            
            self.viewControllers = viewcontrollers;
        }
    }
    
    return self;
}

- (NSArray *)toolbarItems
{
    return self.selectedViewController.toolbarItems;
}

- (id)initWithViewControllers:(NSArray *)viewControllers style:(TSCNavigationTabBarViewStyle)style
{
    if (self = [super init]) {
        
        self.viewStyle = style;
        self.viewControllers = viewControllers;
        
    }
    
    return self;
}


- (id)initWithViewControllers:(NSArray *)viewControllers
{
    return [self initWithViewControllers:viewControllers style:TSCNavigationTabBarViewStyleBelowNavigationBar];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.navigationItem.leftBarButtonItems.count > 0) {
        self.definesOwnLeftNavigationItems = true;
    }
    
    if (self.navigationItem.rightBarButtonItems.count > 0) {
        self.definesOwnRightNavigationItems = true;
    }
    
    self.selectedIndex = 0;

}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (self.viewStyle == TSCNavigationTabBarViewStyleInsideNavigationBar) {
        
        self.selectedViewController.view.frame = self.view.bounds;
        
    } else {
        
        CGRect viewFrame = self.view.bounds;
        viewFrame.origin.y += 40;
        viewFrame.size.height -= 40;
        self.selectedViewController.view.frame = viewFrame;
        
        [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    }
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    _viewControllers = viewControllers;
    self.segmentedView = [[UIView alloc] init];
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:[self TSC_titlesForViewControllers:viewControllers]];
    if (![TSCThemeManager isOS7]) self.segmentedControl.tintColor = [[TSCThemeManager sharedTheme] mainColor];
    [self.segmentedControl setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 120, 25)];
    [self.segmentedControl addTarget:self action:@selector(TSC_handleSelectedIndexChange:) forControlEvents:UIControlEventValueChanged];
    
    if (self.viewStyle == TSCNavigationTabBarViewStyleInsideNavigationBar) {
        self.navigationItem.titleView = self.segmentedControl;
    }
    
    if (self.viewStyle == TSCNavigationTabBarViewStyleBelowNavigationBar) {
        self.segmentedControl.tintColor = [UIColor whiteColor];
        self.segmentedView.backgroundColor = [[TSCThemeManager sharedTheme] mainColor];
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
    
    if (self.observingRightBarItems) {
        
        [self.selectedViewController.navigationItem removeObserver:self forKeyPath:@"rightBarButtonItems"];
        [self.selectedViewController.navigationItem removeObserver:self forKeyPath:@"rightBarButtonItem"];
    }
    
    if (self.observingLeftBarItems) {
        
        [self.selectedViewController.navigationItem removeObserver:self forKeyPath:@"leftBarButtonItems"];
        [self.selectedViewController.navigationItem removeObserver:self forKeyPath:@"leftBarButtonItem"];
    }
    
    _selectedIndex = [self.viewControllers indexOfObject:selectedViewController];
    _selectedViewController = selectedViewController;
    _segmentedControl.selectedSegmentIndex = [self.viewControllers indexOfObject:_selectedViewController];
    
    [self.selectedViewController willMoveToParentViewController:self];
    [self addChildViewController:self.selectedViewController];
    
    // Makes sure if the user has set the button items on the parent "Container" navigation item we don't override them with the child view controllers.
    
    if (!self.definesOwnRightNavigationItems) {
        self.navigationItem.rightBarButtonItems = self.selectedViewController.navigationItem.rightBarButtonItems;
    }
    
    if (!self.definesOwnLeftNavigationItems) {
        self.navigationItem.leftBarButtonItems = self.selectedViewController.navigationItem.leftBarButtonItems;
    }
    
    if (self.selectedViewController.navigationItem.rightBarButtonItems.count > 0) {
        
        self.observingRightBarItems = true;
        [self.selectedViewController.navigationItem addObserver:self forKeyPath:@"rightBarButtonItems" options:kNilOptions context:nil];
        [self.selectedViewController.navigationItem addObserver:self forKeyPath:@"rightBarButtonItem" options:kNilOptions context:nil];
    } else {
        self.observingRightBarItems = false;
    }
    
    if (self.selectedViewController.navigationItem.leftBarButtonItems.count > 0) {
        
        self.observingLeftBarItems = true;
        [self.selectedViewController.navigationItem addObserver:self forKeyPath:@"leftBarButtonItems" options:kNilOptions context:nil];
        [self.selectedViewController.navigationItem addObserver:self forKeyPath:@"leftBarButtonItem" options:kNilOptions context:nil];
    } else {
        
        self.observingLeftBarItems = false;
    }

    [self.view addSubview:self.selectedViewController.view];
    [self viewWillLayoutSubviews];
    [self.selectedViewController didMoveToParentViewController:self];
    
    if (TSC_isPad()) {
        
        [self.selectedViewController viewWillAppear:true];
        [self.selectedViewController viewDidAppear:true];
    }
    
    if (self.viewStyle == TSCNavigationTabBarViewStyleBelowNavigationBar) {
        
        [self.segmentedView removeFromSuperview];
        [self.view addSubview:self.segmentedView];

        self.segmentedView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 40);
        self.segmentedControl.frame = CGRectMake(10, 5, self.view.bounds.size.width - 20, 30);
        [self.segmentedView addSubview:self.segmentedControl];
    }
    
    if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"TSCNavigationTabBarSelectionShouldUpdateTitle"] && [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"TSCNavigationTabBarSelectionShouldUpdateTitle"] boolValue]) {
        self.title = self.selectedViewController.title;
    }
    
    [self.navigationController.view setNeedsLayout];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    if (self.viewControllers.count > 0 && ![self.viewControllers[selectedIndex] isEqual:[NSNull null]]) {
        self.selectedViewController = self.viewControllers[selectedIndex];
    }
}

- (NSArray *)TSC_titlesForViewControllers:(NSArray *)viewControllers
{
    NSMutableArray *viewControllerTitles = [NSMutableArray arrayWithCapacity:viewControllers.count];
    
    for (UIViewController *viewController in viewControllers) {
        
        if (viewController.title) {
            [viewControllerTitles addObject:viewController.title];
        } else {
            [viewControllerTitles addObject:@"No title"];
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
 
    if ([keyPath isEqualToString:@"leftBarButtonItem"] && !self.definesOwnLeftNavigationItems) {
        self.navigationItem.leftBarButtonItem = self.selectedViewController.navigationItem.leftBarButtonItem;
    }
    
    if ([keyPath isEqualToString:@"rightBarButtonItem"] && !self.definesOwnRightNavigationItems) {
        self.navigationItem.rightBarButtonItem = self.selectedViewController.navigationItem.rightBarButtonItem;
    }
    
    if ([keyPath isEqualToString:@"leftBarButtonItems"] && !self.definesOwnLeftNavigationItems) {
        self.navigationItem.leftBarButtonItems = self.selectedViewController.navigationItem.leftBarButtonItems;
    }
    
    if ([keyPath isEqualToString:@"rightBarButtonItems"] && !self.definesOwnRightNavigationItems) {
        self.navigationItem.rightBarButtonItems = self.selectedViewController.navigationItem.rightBarButtonItems;
    }
}

@end
