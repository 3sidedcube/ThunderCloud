//
//  TSCSplitViewController.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 18/12/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A subclass of `UISplitViewController` that gives easier access to the root split view of an iPad application via a shared instance.
 
 This class also gives easier ways to both push and present view controllers, whether it be as a full screen modal, in the master view or detail view
 */
@interface TSCSplitViewController : UISplitViewController <UISplitViewControllerDelegate>

/**
 Returns the root shared instance of `TSCSplitViewController` for the running app
 */
+ (TSCSplitViewController *)sharedController;

/**
 Sets the view controller for the master view of the `UISplitViewController`
 @param viewController The view controller to show in the master view
 @note This will automatically wrap the view controller in a `UINavigationController` if it isn't an instance or contained in one
 */
- (void)setLeftViewController:(id)viewController;

/**
 Sets the view controller for the detail view of the `UISplitViewController` by pulling a retained `UIViewController` out of the `TSCSplitViewController`s memory
 @param retainKey The retain key to check for a `UIViewController` instance for
 @discussion If there is currently a `UINavigationController` being retained for the given key that `UIViewController` will be displayed
 @note This will automatically wrap the view controller in a `UINavigationController` if it isn't an instance or contained in one
 */
- (void)setRightViewControllerUsingRetainKey:(NSString *)retainKey;


/**
 Sets the view controller for the detail view of the `UISplitViewController`
 @param viewController The `UIViewController` to be set or pushed in the detail view
 @param navController The `UINavigationController` that should show the view
 */
- (void)setRightViewController:(id)viewController fromNavigationController:(UINavigationController *)navController;

/**
 Sets the view controller for the detail view of the `UISplitViewController` and retains the `UIViewController` in memory
 @param viewController The `UIViewController` to be set or pushed in the detail view
 @param navController The `UINavigationController` that should show the view
 @param retainKey The key to retain the `UIViewController` under
 @discussion If the navController parameter is the currently displayed `UIViewController` in the master view or is contained in a `TSCAccordionTabBarViewController` the view will just appear in the detail view, otherwise it will be pushed by the detail view's `UINavigationController`
 */
- (void)setRightViewController:(id)viewController fromNavigationController:(UINavigationController *)navController usingRetainKey:(NSString *)retainKey;

/**
 Pushes a `UIViewController` on the master view
 @param viewController The `UIViewController`to push on the master view's navigation stack
 @discussion if the current master view isn't contained in a `UINavigationController` this will wrap it in one and then push the viewController
 */
- (void)pushLeftViewController:(UIViewController *)viewController;

/**
 Pushes a `UIViewController` on the detail view
 @param viewController The `UIViewController`to push on the detail view's navigation stack
 */
- (void)pushRightViewController:(UIViewController *)viewController;

/**
 Presents a fullscreen `UIViewController` from the `UISplitViewController`
 @param viewController The `UIViewController` to be presented as a fullscreen view
 @param animated Whether the presentation should be animated
 */
- (void)presentFullScreenViewController:(UIViewController *)viewController animated:(BOOL)animated;

/**
 Presents a fullscreen `UIViewController` from the `UISplitViewController` and optionally dismisses any popover view currently being shown
 @param viewController The `UIViewController` to be presented as a fullscreen view
 @param animated Whether the presentation should be animated
 @param dismissPopover Whether any currently presented popovers should be dismissed once the `UIViewController` has been presented
 */
- (void)presentFullScreenViewController:(UIViewController *)viewController animated:(BOOL)animated dismissPopover:(BOOL)dismissPopover;

/**
 Returns whether or not a `UIViewController` has been retained for a certain retainKey
 @param retainKey The key to check if a `UIViewController` has been retained for
 */
- (BOOL)retainKeyAlreadyStored:(NSString *)retainKey;

/**
 Resets the shared instance of `TSCSplitViewController`
 @discussion This simply sets the shared instance of `TSCSplitViewController` to nil, it will not remove any `UIViewController`s or the split view itself from the current applications view hierarchy
 */
- (void)resetSharedController;

/**
 The button used to display the master view controller
 @discussion This button will be displayed as the `leftBarButtonItem` of the detail view
 */
@property (nonatomic, strong) UIBarButtonItem *menuButton;

/**
 The currently displayed `UIViewController` in the master view of the split view
 */
@property (nonatomic, strong) id primaryViewController;

/**
 The currently displayed `UIViewController` in the detail view of the split view
 */
@property (nonatomic, strong) id detailViewController;

@end
