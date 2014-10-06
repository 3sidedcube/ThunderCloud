//
//  TSCBadge.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 20/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCBadge.h"
@import ThunderBasics;

@implementation TSCBadge

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    
    if (self) {
        
        self.badgeCompletionText = TSCLanguageDictionary(dictionary[@"completion"]);
        self.badgeHowToEarnText = TSCLanguageDictionary(dictionary[@"how"]);
        self.badgeIcon = dictionary[@"icon"];
        self.badgeShareMessage = TSCLanguageDictionary(dictionary[@"shareMessage"]);
        self.badgeTitle = TSCLanguageDictionary(dictionary[@"title"]);
        self.badgeId = dictionary[@"id"];
    }
    
    return self;
}

@end