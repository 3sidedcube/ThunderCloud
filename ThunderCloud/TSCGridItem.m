//
//  TSCGridItem.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 27/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCGridItem.h"
@import ThunderTable;
@import ThunderBasics;
#import <ThunderCloud/ThunderCloud-Swift.h>

@implementation TSCGridItem

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    return [self initWithDictionary:dictionary parentObject:nil];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject
{
    if (self = [super init]) {
        
        self.itemClass = [NSString stringWithFormat:@"TSC%@", dictionary[@"class"]];
        self.title = TSCLanguageDictionary(dictionary[@"title"]);
        
        if (dictionary[@"description"]) {
            self.itemDescription = TSCLanguageDictionary(dictionary[@"description"]);
        }
        
        self.link = dictionary[@"link"];
		
		if (dictionary[@"image"]) {
			self.image = [TSCImage imageWithJSONObject:dictionary[@"image"]];
		}
		
        if (dictionary[@"badgeId"]) {
            
            NSString *stringBadgeId = [NSString stringWithFormat:@"%@",dictionary[@"badgeId"]];
            
            TSCBadge *gridBadge = [[TSCBadgeController sharedController] badgeFor:stringBadgeId];
			
            self.image = gridBadge.icon;
            self.badgeId = stringBadgeId;
        }
    }
    
    return self;
}

@end
