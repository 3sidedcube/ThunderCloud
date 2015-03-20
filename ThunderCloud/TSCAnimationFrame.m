//
//  TSCAnimationFrame.m
//  ThunderCloud
//
//  Created by Matthew Cheetham on 20/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

#import "TSCAnimationFrame.h"

@implementation TSCAnimationFrame

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        
        self.delay = dictionary[@"delay"];
        self.image = [TSCImage imageWithJSONObject:dictionary[@"image"]];
        
    }
    return self;
}

@end
