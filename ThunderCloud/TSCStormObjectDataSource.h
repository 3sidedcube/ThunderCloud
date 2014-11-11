//
//  TSCStormObjectDataSource.h
//  ThunderCloud
//
//  Created by Phillip Caudell on 09/04/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 All objects used in storm can optionally conform to the `TSCStormObjectDataSource`. This dataSource provides access to additional information about storm objects
 */
@protocol TSCStormObjectDataSource <NSObject>

/**
 @abstract An array of storm attributes used generally to describe additional customisation for an object
 */
- (NSArray *)stormAttributes;

/**
 @abstract A reference to the parent object of this storm object
 */
- (id)stormParentObject;

/**
 @abstract The setter for setting the parent storm object
 */
- (void)setStormParentObject:(id)parentObject;

@end
