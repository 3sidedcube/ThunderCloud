//
//  RCAlertManagementHubViewController.h
//  American Red Cross Disaster
//
//  Created by Phillip Caudell on 29/08/2013.
//  Copyright (c) 2013 madebyphill.co.uk. All rights reserved.
//

@import UIKit;

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

- (id)initWithDictionary:(NSDictionary *)dictionary;
-(id)initWithViewControllers:(NSArray *)viewControllers;

@end
