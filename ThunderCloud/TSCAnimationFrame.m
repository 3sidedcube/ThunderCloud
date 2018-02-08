//
//  TSCAnimationFrame.m
//  ThunderCloud
//
//  Created by Matthew Cheetham on 20/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

#import "TSCAnimationFrame.h"
#import <ThunderCloud/ThunderCloud-Swift.h>

@implementation TSCAnimationFrame

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        
        self.delay = dictionary[@"delay"];
		self.image = [TSCStormGenerator imageFromJSON:dictionary[@"image"]];
        
    }
    return self;
}

@end
