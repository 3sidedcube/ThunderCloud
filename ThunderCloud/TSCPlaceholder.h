//
//  TSCPlaceholder.h
//  ThunderStorm
//
//  Created by Andrew Hart on 02/01/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

@import UIKit;

/**
 A model representation of a `UITabBarItem` for use in a `TSCAccordionTabBarViewController`
 */
@interface TSCPlaceholder : NSObject

/**
 Initializes a new placeholder with a dictionary
 @param dictionary The dictionary to allocate a `TSCPlaceholder` from
 */
- (id)initWithDictionary:(NSDictionary *)dictionary;

/**
 The tab title
 */
@property (nonatomic, copy) NSString *title;

/**
 The tab description
 */
@property (nonatomic, copy) NSString *placeholderDescription;

/**
 The tab icon image
 */
@property (nonatomic, strong) UIImage *image;

@end
