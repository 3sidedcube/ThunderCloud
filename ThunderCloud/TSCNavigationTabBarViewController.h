//
//  RCAlertManagementHubViewController.h
//  American Red Cross Disaster
//
//  Created by Phillip Caudell on 29/08/2013.
//  Copyright (c) 2013 madebyphill.co.uk. All rights reserved.
//

@import UIKit;

/**
 `TSCNavigationTabBarViewController` is a subclass of UIViewController which allows for a tab to switch between view controllers within a UINavigationController.
 
 
 This class listens to changes on the navigation items of it's child view controllers so will change the left and right navigation items as you tab between the children.
 
 If you want to have shared navigation items between all of the children please make sure when subclassing this class to set any shared navigationItems within your -initWithDictionary: method.
 */
@interface TSCNavigationTabBarViewController : UIViewController

typedef enum {
    TSCNavigationTabBarViewStyleInsideNavigationBar = 0,
    TSCNavigationTabBarViewStyleBelowNavigationBar = 1
} TSCNavigationTabBarViewStyle;

@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UIView *segmentedView;
@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, strong) UIViewController *selectedViewController;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic) TSCNavigationTabBarViewStyle viewStyle;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithViewControllers:(NSArray *)viewControllers;

@end
