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

/**
 A protocol that alerts a delegate when a tab bar was interacted with
 */
@protocol TSCAccordionTabBarItemDelegate

/**
 Alerts the delegate that the tab bar item was pressed
 */
- (void)tabBarItemWasPressed:(TSCAccordionTabBarItem *)tabBarItem;

@end

/**
 A view representation of a tab bar item to be displayed in a `TSCAccordionTabBarViewController`
 */
@interface TSCAccordionTabBarItem : UIView

/**
 @abstract The title of the tab item
 */
@property (nonatomic, copy) NSString *title;

/**
 @abstract The image of the tab item
 */
@property (nonatomic, strong) UIImage *image;

/**
 @abstract The content view of the tab item
 */
@property (nonatomic, strong) UIView *contentView;

/**
 @abstract Whether the tab item is currently selected
 */
@property (nonatomic, assign) BOOL selected;

/**
 @abstract Keeps track of whether the tab item is the first item in the `TSCAccordionTabBarViewController`
 */
@property (nonatomic, assign) BOOL isFirstItem;

/**
 @abstract Whether the tab item should display it's top border
 */
@property (nonatomic, assign) BOOL showTopBorder;

/**
 @abstract An extra button to be displayed on the tab bar
 @discussion For the purposes of a tab item contained in a `TSCAccordionTabBarViewController` this is the `leftBarButtonItem` of the `UIViewController` represented by this item
 */
@property (nonatomic, strong) UIButton *extraButton;

/**
 @abstract A CALayer used to show the navigation...
 */
@property (nonatomic, strong) CALayer *navigationLayer;

/**
 @abstract The title label for the tab item
 */
@property (nonatomic, strong) UILabel *titleLabel;

/**
 @abstract The icon view for the tab bar item
 */
@property (nonatomic, strong) UIImageView *iconView;

/**
 @abstract A delegate which will have the methods declared in `TSCAccordionTabBarItemDelegate` called on it
 */
@property (nonatomic) id <TSCAccordionTabBarItemDelegate> delegate;

/**
 @abstract Initializes a new item with a given title, image and tag
 @param title The title to be displayed on the item
 @param image The image to be displayed on the item
 @param tag The tag of the item
 */
- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image tag:(NSInteger)tag;

/**
 Provides a UIImage tinted with the chosen colour
 @param color The color to tint the image with
 @param Image The image to be tinted
 */
- (UIImage *)tintImageWithColor:(UIColor *)color Image:(UIImage *)image;

@end