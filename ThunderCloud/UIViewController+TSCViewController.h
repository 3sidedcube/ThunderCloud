//
//  UIViewController+TSCViewController.h
//  ThunderCloud
//
//  Created by Phillip Caudell on 20/05/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 `UIViewController+TSCViewController` is a category that provides convenience methods for `UIViewController`
 */
@interface UIViewController (TSCViewController)

/**
 Sets the pages unique identifier
 @param identifier A unique identifier
 */
- (void)setPageIdentifier:(id)identifier;

/**
 Returns the pages unique identifier
 */
- (id)pageIdenitifer;

@end
