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

@interface TSCNavigationController : UINavigationController < TSCTableRowDataSource>

@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, strong) UITableView *currentTableView;
@property (nonatomic, assign, getter = isSelected) BOOL selected;

@end
