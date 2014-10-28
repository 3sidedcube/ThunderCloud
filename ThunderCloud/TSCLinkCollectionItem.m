//
//  TSCLinkCollectionItem.m
//  ThunderCloud
//
//  Created by Simon Mitchell on 27/10/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

#import "TSCLinkCollectionItem.h"
#import "TSCImage.h"
#import "TSCLink.h"

@implementation TSCLinkCollectionItem

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        
        self.image = [TSCImage imageWithDictionary:dictionary[@"image"]];
        self.link = [[TSCLink alloc] initWithDictionary:dictionary[@"link"]];
    }
    return self;
}

@end
