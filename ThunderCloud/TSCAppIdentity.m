//
//  TSCAppIdentity.m
//  ThunderStorm
//
//  Created by Sam Houghton on 29/01/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import "TSCAppIdentity.h"
#import "TSCStormLanguageController.h"

@implementation TSCAppIdentity

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    return [self initWithDictionary:dictionary parentObject:nil];
}


- (instancetype)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject
{
    if (self = [super init]) {
        
        self.appIdentifier = dictionary[@"appIdentifier"];
        self.iTunesId = dictionary[@"ios"][@"iTunesId"];
        self.countryCode = dictionary[@"ios"][@"countryCode"];
        self.launcher = dictionary[@"ios"][@"launcher"];
        
        if (dictionary[@"name"]) {
            
            NSString *shortLanguageString = [[TSCStormLanguageController sharedController] currentLanguageShortKey];
            self.appName = dictionary[@"name"][shortLanguageString];
            
            if (!self.appName) {
                self.appName = dictionary[@"name"][@"en"];
            }
        }
    }
    
    return self;
}

@end
