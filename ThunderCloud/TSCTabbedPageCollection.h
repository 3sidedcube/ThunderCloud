//
//  TSCTabbedPageCollection.h
//  ThunderStorm
//
//  Created by Phillip Caudell on 23/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTSCTabbedPageCollectionUsersPreferedOrderKey @"TSCTabbedPageCollectionUsersPreferedOrder"

/**
 Storm representation `UITabBarController`
 
 Allows initialisation of a `UITabBarController` using a dictionary taken from the app bundle
 - Implements a custom "more" page if it is provided with more than 5 view controllers
 - Stores tab arrangement to NSUserDefaults
 */
@interface TSCTabbedPageCollection : UITabBarController <UITabBarControllerDelegate>

/**
 Initializes a `TSCTabbedPageCollection` using a dictionary representation
 @param dictionary The dictionary representation of a tabbed page collection
 @param parentObject The containing object of the `TSCTabbedPageCollection` 
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)object;

@end
