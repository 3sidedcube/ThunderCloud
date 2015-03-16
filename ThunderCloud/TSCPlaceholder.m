//
//  TSCPlaceholder.m
//  ThunderStorm
//
//  Created by Andrew Hart on 02/01/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import "TSCPlaceholder.h"
#import "TSCImage.h"
@import ThunderBasics;

@implementation TSCPlaceholder

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        self.title = TSCLanguageDictionary(dictionary[@"title"]);
        self.placeholderDescription = TSCLanguageDictionary(dictionary[@"description"]);
        self.image = [TSCImage imageWithDictionary:dictionary[@"placeholderImage"]];
    }
    
    return self;
}

@end
