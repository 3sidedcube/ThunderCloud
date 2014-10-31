//
//  TSCCoordinate.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 14/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCCoordinate.h"

@implementation TSCCoordinate

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        
        id x = dictionary[@"x"];
        if (![x isEqual:[NSNull null]]) self.x = [x floatValue];
        id y = dictionary[@"y"];
        if (![y isEqual:[NSNull null]]) self.y = [y floatValue];
        id z = dictionary[@"z"];
        if (![z isEqual:[NSNull null]]) self.z = [z floatValue];
    }
    
    return self;
}

@end
