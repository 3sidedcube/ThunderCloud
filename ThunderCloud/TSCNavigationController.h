//
//  TSCNavigationControllerController.h
//  ThunderCloud
//
//  Created by Phillip Caudell on 10/04/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

@import UIKit;
@import ThunderTable;
#import "TSCNavigationBarDataSource.h"

/**
 `TSCNavigationController` is a subclass of UINavigationController that provides convenient methods. It is also a `TSCTableRowDataSource` for when it is being dislpayed in a more tab.
 */
@interface TSCNavigationController : UINavigationController /*<TSCTableRowDataSource>*/

/**
 @abstract The `UIViewController` that is currently being displayed
 */
@property (nonatomic, strong) UIViewController *currentViewController;

/**
 @abstract The current `UITableView` that is being displayed inside of the navigation controller
 */
@property (nonatomic, strong) UITableView *currentTableView;

/**
 @abstract Bool that represents whether the row representation has been selected
 */
@property (nonatomic, assign, getter = isSelected) BOOL selected;

@end
