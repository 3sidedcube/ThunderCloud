//
//  TSCTabBarMoreViewController.m
//  ThunderCloud
//
//  Created by Sam Houghton on 16/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

#import "TSCTabBarMoreViewController.h"
#import "NSString+LocalisedString.h"

@interface TSCTabBarMoreViewController () <UINavigationControllerDelegate>

@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, weak) UINavigationController *pushedNavigationController;
@property (nonatomic, weak) UIViewController *pushedViewController;

@end

@implementation TSCTabBarMoreViewController

- (instancetype)initWithViewControllers:(NSArray *)viewControllers
{
    if (self = [super init]) {
        
        self.viewControllers = viewControllers;
        self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:5];
        self.title = [NSString stringWithLocalisationKey:@"_MORE_NAVIGATION_TITLE" fallbackString:@"More"];
        self.navigationController.delegate = self;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableArray *viewControllers = [NSMutableArray array];
    
    for (UIViewController *viewController in self.viewControllers) {
        
        TSCTableRow *row = [TSCTableRow rowWithTitle:viewController.tabBarItem.title subtitle:nil image:viewController.tabBarItem.image];
        [viewControllers addObject:row];
    }
    
    TSCTableSection *navigationControllerSection = [TSCTableSection sectionWithTitle:nil footer:nil items:viewControllers target:self selector:@selector(handleViewController:)];
    
    self.dataSource = @[navigationControllerSection];
}

- (void)handleViewController:(TSCTableSelection *)selection
{
    [self.tableView deselectRowAtIndexPath:selection.indexPath animated:true];
    self.navigationController.delegate = self;
    UIViewController *viewController = self.viewControllers[selection.indexPath.row];
    
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        
        self.pushedNavigationController = (UINavigationController *)viewController;
        if (self.pushedNavigationController.viewControllers.count > 0) {
            
            self.pushedViewController = self.pushedNavigationController.viewControllers[0];
            [self.navigationController pushViewController:self.pushedNavigationController.viewControllers[0] animated:true];
        } else if (self.pushedNavigationController.topViewController) {
            
            self.pushedViewController = self.pushedNavigationController.topViewController;
            [self.navigationController pushViewController:self.pushedNavigationController.topViewController animated:true];
        }
    } else {
        [self.navigationController pushViewController:viewController animated:true];
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController == self) {
        self.pushedNavigationController.viewControllers = @[self.pushedViewController];
    }
}

@end
