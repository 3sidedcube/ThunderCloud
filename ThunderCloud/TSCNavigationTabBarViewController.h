//
//  RCAlertManagementHubViewController.h
//  American Red Cross Disaster
//
//  Created by Phillip Caudell on 29/08/2013.
//  Copyright (c) 2013 madebyphill.co.uk. All rights reserved.
//

@import UIKit;

/**
 `TSCNavigationTabBarViewController` is a subclass of UIViewController which displays a `UISegmentedControl` to switch between view controllers within a `UINavigationController`.
 
 This class listens to changes on the navigation items of it's child view controllers so will change the left and right navigation items as you tab between the children.
 
 If you want to have shared navigation items between all of the children please make sure when subclassing this class to set any shared navigationItems within your -initWithDictionary: method.
 */
@interface TSCNavigationTabBarViewController : UIViewController

/** Defines different styles of `TSCNavigationTabBarViewController` */
typedef enum {
    /** The `UISegmentedControl` will be shown within the `UINavigationController`'s `UINavigationBar` */
    TSCNavigationTabBarViewStyleInsideNavigationBar = 0,
    /** The `UISegmentedControl` will be shown below the `UINavigationController`'s `UINavigationBar` */
    TSCNavigationTabBarViewStyleBelowNavigationBar = 1
} TSCNavigationTabBarViewStyle;

/**
 Initializes a new instance with a dictionary representation of a `TSCNavigationTabBarViewController`
 @param dictionary The dictionary to initialize and set up the instance with
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 Initializes a new instance with an array of `UIViewController`s
 @param viewControllers The array of `UIViewController`s to display in the instance
 */
- (instancetype)initWithViewControllers:(NSArray *)viewControllers;

/**
 Initializes a new instance with an array of `UIViewController`s
 @param viewControllers The array of `UIViewController`s to display in the instance
 @param style The style to use with the `TSCNavigationTabBarViewController`
 */
- (instancetype)initWithViewControllers:(NSArray *)viewControllers style:(TSCNavigationTabBarViewStyle)style;

/**
 The segmented control which allows switching between the `UIViewController`s
 */
@property (nonatomic, strong) UISegmentedControl *segmentedControl;

/**
 The containing view for the `UISegmentedControl` which manages the selected view controller
 */
@property (nonatomic, strong) UIView *segmentedView;


/**
 The array of `UIViewController` which the user can toggle between
 @discussion Setting of this manually is not tested, however it should behave fine and update the `UISegmentedControl` to reflect the change
 */
@property (nonatomic, strong) NSArray *viewControllers;

/**
 The currently selected `UIViewController`
 @discussion Setting this manually will update the currently displayed view controller and the selection state of the `UISegmentedControl`.
 @warning Will crash or cause un-expected behaviour if set to a `UIViewController` not contained in `viewControllers`
 */
@property (nonatomic, strong) UIViewController *selectedViewController;

/**
 The index of the currently selected `UIViewController`
 @discussion Setting this will select the view controller at that index and update the `UISegmentedControl` to reflect the change
 */
@property (nonatomic, assign) NSInteger selectedIndex;

/**
 The current style of the `TSCNavigationTabBarViewController`
 @discussion Setting this will not update the style once initialization has been called until re-setting `viewControllers`
 @warning Setting this may lead to un-expected behaviour or even crashing and has not been tested thoroughly
 */
@property (nonatomic) TSCNavigationTabBarViewStyle viewStyle;

@end
