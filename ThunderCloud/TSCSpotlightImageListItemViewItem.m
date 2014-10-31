//
//  TSCSpotlightImageListItemViewItem.m
//  ThunderStorm
//
//  Created by Andrew Hart on 11/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCSpotlightImageListItemViewItem.h"
#import "TSCImage.h"
#import "TSCLink.h"
@import ThunderBasics;

@implementation TSCSpotlightImageListItemViewItem

- (id)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject
{
    if (self = [super initWithDictionary:dictionary parentObject:parentObject]) {
        
        self.image = [TSCImage imageWithDictionary:dictionary];
        self.delay = [dictionary[@"delay"] integerValue];
        self.spotlightText = TSCLanguageDictionary(dictionary[@"text"]);

        if (dictionary[@"link"][@"destination"]) {
            self.link = [[TSCLink alloc] initWithDictionary:dictionary[@"link"]];
        }
    }
    
    return self;
}

@end
