//
//  TSCArea.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 14/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCZone.h"
#import "TSCCoordinate.h"

@implementation TSCZone

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        
        self.coordinates = [NSMutableArray array];
        
        for (NSDictionary *coordinateDict in dictionary[@"coordinates"]) {
            
            TSCCoordinate *coord = [[TSCCoordinate alloc] initWithDictionary:coordinateDict];
            
            [self.coordinates addObject:coord];
        }
    }
    
    return self;
}

- (BOOL)containsPoint:(CGPoint)point
{
    TSCCoordinate *topLeft = self.coordinates[0];
    TSCCoordinate *topRight = self.coordinates[1];
    TSCCoordinate *bottomLeft = self.coordinates[3];
    
    if ((point.x > topLeft.x) && (point.x < topRight.x) && (point.y > topLeft.y) && (point.y < bottomLeft.y)) {
        return YES;
    }
    
    return NO;
}

@end
