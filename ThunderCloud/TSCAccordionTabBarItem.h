//
//  TSCAccordionTabBarItem.h
//  ThunderStorm
//
//  Created by Andrew Hart on 20/12/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSCNavigationTabBarViewController.h"

#define ACCORDION_TAB_BAR_ITEM_HEIGHT 45

@class TSCAccordionTabBarItem;

@protocol TSCAccordionTabBarItemDelegate

- (void)tabBarItemWasPressed:(TSCAccordionTabBarItem *)tabBarItem;

@end

@interface TSCAccordionTabBarItem : UIView

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic) id <TSCAccordionTabBarItemDelegate> delegate;

- (id)initWithTitle:(NSString *)title image:(UIImage *)image tag:(NSInteger)tag;

@end