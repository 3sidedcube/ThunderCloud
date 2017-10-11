//
//  TSCAppCollectionItem.m
//  ThunderCloud
//
//  Created by Matt Cheetham on 26/06/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import "TSCAppCollectionItem.h"
#import "TSCImage.h"
#import "TSCAppLinkController.h"
#import "ThunderCloud/ThunderCloud-Swift.h"
@import ThunderBasics;

@implementation TSCAppCollectionItem

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        
        self.appIcon = [TSCImage imageWithJSONObject:dictionary[@"icon"]];
        self.appIdentity = [[TSCAppLinkController sharedController] appForId:dictionary[@"identifier"]];
        self.appName = [[TSCStormLanguageController sharedController] stringForKey:(dictionary[@"name"])];
        if (self.appIdentity.appName) {
            self.appName = self.appIdentity.appName;
        }
        self.appPrice = [[TSCStormLanguageController sharedController] stringForDictionary:(dictionary[@"overlay"])];
    }
    
    return self;
}

@end
