//
//  TSCCoordinate.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 14/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@import UIKit;

/**
 An object representing a 3D point in a cartesian vector space
 */
@interface TSCCoordinate : NSObject

/**
 @abstract Initializes a new coordinate from a CMS representation
 @param dictionary The dictionary to initiate a coordinate using
 */
- (id)initWithDictionary:(NSDictionary *)dictionary;

/**
 @abstract The x component of the coordinate
 */
@property (nonatomic) CGFloat x;

/**
 @abstract The y component of the coordinate
 */
@property (nonatomic) CGFloat y;

/**
 @abstract The z component of the coordinate
 */
@property (nonatomic) CGFloat z;

@end
