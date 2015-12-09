//
//  TSCTabBarMoreViewController.h
//  ThunderCloud
//
//  Created by Sam Houghton on 16/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

@import ThunderTable;

/**
 A re-implementation of the iOS standard "More" tab
 */
@interface TSCTabBarMoreViewController : TSCTableViewController

/**
 Initializes a new instance with an array of `UIViewController`s
 @param viewControllers The array of `UIViewController`s to display in the tablee
 */
- (instancetype)initWithViewControllers:(NSArray *)viewControllers;

@end
