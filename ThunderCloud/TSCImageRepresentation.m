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
        self.dimensions = CGSizeMake([dictionary[@"dimensions"][@"width"] floatValue], [dictionary[@"dimensions"][@"height"] floatValue]);
        self.mimeType = dictionary[@"mime"];
        self.byteSize = dictionary[@"size"];
        self.locale = dictionary[@"locale"];
        
    }
    return self;
}

@end
