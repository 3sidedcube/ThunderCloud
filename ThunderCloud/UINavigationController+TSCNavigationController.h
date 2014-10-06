//
//  UINavigationController+TSCNavigationController.h
//  ThunderStorm
//
//  Created by Phillip Caudell on 11/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSCLink;

@interface UINavigationController (TSCNavigationController)

+ (UINavigationController *)sharedController;

- (void)pushLink:(TSCLink *)link;
- (void)pushVideos:(NSArray *)videos;
+ (void)registerNativeLink:(NSString *)nativeLinkName toViewControllerClass:(Class)viewControllerClass;
- (void)pushNativeViewController:(UIViewController *)nativeViewController animated:(BOOL)animated;

@end
