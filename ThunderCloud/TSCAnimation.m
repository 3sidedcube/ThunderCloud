//
//  TSCAnimation.m
//  ThunderCloud
//
//  Created by Matthew Cheetham on 20/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

#import "TSCAnimation.h"
#import "TSCAnimationFrame.h"
@import ThunderBasics;

@implementation TSCAnimation

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        
        self.animationFrames = [NSArray arrayWithArrayOfDictionaries:dictionary[@"frames"] rootInstanceType:[TSCAnimationFrame class]];
        
        if(dictionary[@"looped"]) {
            self.looped = [dictionary[@"looped"] boolValue];
        }
        
    }
    return self;
}

@end
