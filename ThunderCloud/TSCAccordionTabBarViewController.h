//
//  TSCAccordionTabBarViewController.h
//  ThunderStorm
//
//  Created by Andrew Hart on 20/12/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSCAccordionTabBarItem.h"

@interface TSCAccordionTabBarViewController : UIViewController

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject;

@property (nonatomic, retain) NSMutableArray *accordionTabBarItems;
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) NSMutableArray *placeholders;
@property (nonatomic, strong) UIViewController *selectedViewController;
@property (nonatomic) NSInteger selectedTabIndex;

@end
