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

@implementation TSCAppCollectionItem

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        
        self.appIcon = [TSCImage imageWithDictionary:dictionary[@"icon"]];
        self.appIdentity = [[TSCAppLinkController sharedController] appForId:dictionary[@"identifier"]];
    }
    
    return self;
}


@end
