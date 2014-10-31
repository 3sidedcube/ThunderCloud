//
//  TSCAppIdentity.m
//  ThunderStorm
//
//  Created by Sam Houghton on 29/01/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import "TSCAppIdentity.h"

@implementation TSCAppIdentity

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    return [self initWithDictionary:dictionary parentObject:nil];
}


- (id)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject
{
    if (self = [super init]) {
        self.appIdentifier = dictionary[@"appIdentifier"];
        self.iTunesId = dictionary[@"ios"][@"iTunesId"];
        self.countryCode = dictionary[@"ios"][@"countryCode"];
        self.launcher = dictionary[@"ios"][@"launcher"];
    }
    
    return self;
}

@end
