//
//  TSCTabbedPageCollection.h
//  ThunderStorm
//
//  Created by Phillip Caudell on 23/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTSCTabbedPageCollectionUsersPreferedOrderKey @"TSCTabbedPageCollectionUsersPreferedOrder"

@interface TSCTabbedPageCollection : UITabBarController <UITabBarControllerDelegate>

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
