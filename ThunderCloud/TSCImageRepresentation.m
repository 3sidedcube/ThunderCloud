//
//  TSCImageRepresentation.m
//  ThunderCloud
//
//  Created by Matthew Cheetham on 17/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

#import "TSCImageRepresentation.h"
#import "TSCLink.h"

@implementation TSCImageRepresentation

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        
        self.sourceLink = [[TSCLink alloc] initWithDictionary:dictionary[@"src"]];
        
        CGFloat dimensionHeight = (dictionary[@"dimensions"][@"height"] != [NSNull null]) ? [dictionary[@"dimensions"][@"height"] floatValue] : 0;
        CGFloat dimensionWidth = (dictionary[@"dimensions"][@"width"] != [NSNull null]) ? [dictionary[@"dimensions"][@"width"] floatValue] : 0;

        self.dimensions = CGSizeMake(dimensionWidth, dimensionHeight);
        self.mimeType = dictionary[@"mime"];
        self.byteSize = dictionary[@"size"];
        self.locale = dictionary[@"locale"];
        
    }
    return self;
}

@end
