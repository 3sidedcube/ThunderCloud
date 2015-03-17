//
//  TSCNavigationBarDataSource.h
//  ThunderCloud
//
//  Created by Phillip Caudell on 10/04/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Any `UIViewController` can comply to this delegate. `UINavigationController+TSCNavigationController` uses this method to determine whether the navigation bar should be tranparent or not.
 */
@protocol TSCNavigationBarDataSource <NSObject>

@optional
/**
 Can be used in any `UIViewController` to determine whether the navigation bar should be tranparent or not. If the return value is changed call `- setNeedsNavigationBarAppearanceUpdateAnimated:animated` on the navigation controller to update the navigation bars appearence.
 */
- (BOOL)shouldHideNavigationBar;

@end
