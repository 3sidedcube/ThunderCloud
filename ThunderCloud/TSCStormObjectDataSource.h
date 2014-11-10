//
//  TSCStormObjectDataSource.h
//  ThunderCloud
//
//  Created by Phillip Caudell on 09/04/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TSCStormObjectDataSource <NSObject>

- (NSArray *)stormAttributes;
- (id)stormParentObject;
- (void)setStormParentObject:(id)parentObject;

@end
