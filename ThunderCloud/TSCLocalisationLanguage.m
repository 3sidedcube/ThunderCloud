//
//  TSCLocalisationLanguage.m
//  ThunderCloud
//
//  Created by Matthew Cheetham on 17/09/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

#import "TSCLocalisationLanguage.h"

@implementation TSCLocalisationLanguage

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        
        self.uniqueIdentifier = dictionary[@"id"];
        self.languageCode = dictionary[@"code"];
        self.languageName = dictionary[@"name"];
        self.isPublishable = dictionary[@"publishable"];
        
    }
    
    return self;
}

@end
