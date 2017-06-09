//
//  TSCBadge.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 20/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCBadge.h"
#import "ThunderCloud/ThunderCloud-Swift.h"
@import ThunderBasics;

@implementation TSCBadge

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        
        self.badgeCompletionText = [[TSCStormLanguageController sharedController] stringForDictionary:(dictionary[@"completion"])];
        self.badgeHowToEarnText = [[TSCStormLanguageController sharedController] stringForDictionary:(dictionary[@"how"])];
        self.badgeIcon = dictionary[@"icon"];
        self.badgeShareMessage = [[TSCStormLanguageController sharedController] stringForDictionary:(dictionary[@"shareMessage"])];
        self.badgeTitle = [[TSCStormLanguageController sharedController] stringForDictionary:(dictionary[@"title"])];
        
        if (dictionary[@"id"]) {
            self.badgeId = [NSString stringWithFormat:@"%@",dictionary[@"id"]];
        }
    }
    
    return self;
}

@end
