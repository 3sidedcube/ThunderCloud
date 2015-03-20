//
//  TSCAccordionTabBarViewController.h
//  ThunderStorm
//
//  Created by Andrew Hart on 20/12/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSCAccordionTabBarItem.h"

/**
 A subclass of `UIViewController` which replaces `UITabBarController`
 
 `TSCAccordionTabBarViewController` displays the tabs that would be visible in a a `UITabBarController` in a `UITableView` style view with each tab bar being a cell in the view.
 
 When a cell in this table is selected the `UIViewController` for the selected tab is expanded underneath the item's cell and all other "tabs" are minimised. By default the top item is automatically expanded when the view is shown.
 
 This is best used on iPad for displaying tabbed content in the master portion of a `UISplitViewController`.
 */
@interface TSCAccordionTabBarViewController : UIViewController

/**
 Initializes a new `TSCAccordionTabBarViewController` with the provided dictionary representation
 @param dictionary A dictionary representation of a `TSCAccordionTabBarViewController`
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 Initializes a new `TSCAccordionTabBarViewController` with the provided dictionary representation and parent object
 @param dictionary A dictionary representation of a `TSCAccordionTabBarViewController`
 @param parentObject The containing object of the `TSCAccordionTabBarViewController`
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject;

/**
 An array of `TSCAccordionTabBarItem`s that are being shown
 */
@property (nonatomic, retain) NSMutableArray *accordionTabBarItems;

/**
 An array of `UIViewController`s each 'attached' to an individual `TSCAccordionTabBarItem`
 */
@property (nonatomic, strong) NSMutableArray *viewControllers;

/**
 The currently displayed (Expanded) `UIViewController`
 */
@property (nonatomic, strong) UIViewController *selectedViewController;

/**
 The index of the currently expanded tab
 */
@property (nonatomic) NSInteger selectedTabIndex;

@end
