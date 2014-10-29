//
//  TSCGridItem.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 27/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCGridItem.h"
#import "TSCBadge.h"
#import "TSCBadgeController.h"
@import ThunderTable;
@import ThunderBasics;

@implementation TSCGridItem

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    return [self initWithDictionary:dictionary parentObject:nil];
}

- (id)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject
{
    self = [super init];
    
    if (self) {
        
        self.itemClass = [NSString stringWithFormat:@"TSC%@", dictionary[@"class"]];
        self.title = TSCLanguageDictionary(dictionary[@"title"]);
        if (dictionary[@"description"]) {
            self.itemDescription = TSCLanguageDictionary(dictionary[@"description"]);
        }
        self.link = dictionary[@"link"];
        self.image = dictionary[@"image"];
        
        if (dictionary[@"badgeId"]) {
            
            TSCBadge *gridBadge = [[TSCBadgeController sharedController] badgeForId:dictionary[@"badgeId"]];
            self.image = gridBadge.badgeIcon;
           // self.title = gridBadge.badgeTitle;
            self.badgeId = dictionary[@"badgeId"];
        }
    }
    
    return self;
}

@end