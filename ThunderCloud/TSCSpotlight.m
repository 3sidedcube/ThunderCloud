//
//  TSCSpotlight.m
//  ThunderCloud
//
//  Created by Matthew Cheetham on 20/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

#import "TSCSpotlight.h"
#import "TSCImage.h"
#import "TSCLink.h"
#import "TSCStormLanguageController.h"

@implementation TSCSpotlight

- (instancetype)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject
{
    return [self initWithDictionary:dictionary];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super initWithDictionary:dictionary]) {
        
        self.image = [TSCImage imageWithJSONObject:dictionary[@"image"]];
        
        //This is for legacy spotlight image support
        if (!self.image) {
            self.image = [TSCImage imageWithJSONObject:dictionary];
        }
        
        self.delay = [dictionary[@"delay"] integerValue];
        self.spotlightText = TSCLanguageDictionary(dictionary[@"text"]);
        
        if (dictionary[@"link"] && [dictionary[@"link"] isKindOfClass:[NSDictionary class]] && dictionary[@"link"][@"destination"]) {
            self.link = [[TSCLink alloc] initWithDictionary:dictionary[@"link"]];
        }
    }
    
    return self;
}

@end
