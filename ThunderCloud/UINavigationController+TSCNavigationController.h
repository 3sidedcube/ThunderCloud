//
//  UINavigationController+TSCNavigationController.h
//  ThunderStorm
//
//  Created by Phillip Caudell on 11/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSCLink;

/**
 `UINavigationController+TSCNavigationController` is a category that provides convenience methods related to navigation
 */
@interface UINavigationController (TSCNavigationController)

/**
 Returns a shared instance of the `UINavigationController`
 */
+ (UINavigationController *)sharedController;

/**
 Performs an action depending on the `TSCLink` type
 @param link A `TSCLink` to decide which action to perform
 */
- (void)pushLink:(TSCLink *)link;

/**
 Pushes a `TSCMultiVideoPlayerViewController` player on to the screen with an array of `TSCVideo`s
 @param videos An array of `TSCVideo`s
 */
- (void)pushVideos:(NSArray *)videos;

/**
 Registers a native link which is used to push to a native page within the app
 @param nativeLinkName The name of the native link
 @param viewControllerClass The class that should be pushed when the link is used
 */
+ (void)registerNativeLink:(NSString *)nativeLinkName toViewControllerClass:(Class)viewControllerClass;

/**
 Pushes a native view controller on to the navigation stack
 @param nativeViewController The native view controller to be pushed on to the stack
 @param animated Specify YES to animate the transition or NO if you do not want the transition to be animated. You might specify NO if you are setting up the navigation controller at launch time.
 */
- (void)pushNativeViewController:(UIViewController *)nativeViewController animated:(BOOL)animated;

/**
 Reloads the navigation bar appearence. Used if a view needs to switch between transparency e.g. When scrolling down a view you might want the navigation bar to become opaque
 @param animated If the animated is set to YES the navigation bar will animate its alpha change
 */
- (void)setNeedsNavigationBarAppearanceUpdateAnimated:(BOOL)animated;

@end
