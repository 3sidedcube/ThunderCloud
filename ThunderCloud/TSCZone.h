//
//  TSCArea.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 14/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@import Foundation;
@import CoreGraphics;

/**
 A class which represents a zone on an image
 
 Currently a zome is simply a rectangle, but it could be made to support more complex shaped
 */
@interface TSCZone : NSObject

/**
 Initializes a new `TSCZone` from a CMS object representation
 @param dictionary The dictionary to initialize a new zone from
 */
- (id)initWithDictionary:(NSDictionary *)dictionary;

/**
 Returns whether a certain point is contained within the zones bounds
 @param point The point for which to check whether it is within the zones bounds
 */
- (BOOL)containsPoint:(CGPoint)point;

/**
 @abstract An array of `TSCCoordinate` objects which define the bounding coordinates of the zone
 */
@property (nonatomic, strong) NSMutableArray *coordinates;

@end
