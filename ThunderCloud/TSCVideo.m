//
//  TSCVideo.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 16/01/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import "TSCVideo.h"
#import "TSCLink.h"
#import "TSCStormLanguageController.h"

@implementation TSCVideo

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        
        self.videoLocaleString = dictionary[@"locale"];
        self.videoLocale = dictionary[@"locale"];
        self.videoLink = [[TSCLink alloc] initWithDictionary:dictionary[@"src"]];
        
        self.videoLocale = [[TSCStormLanguageController sharedController] localeForLanguageKey:self.videoLocaleString];
    }
    
    return self;
}

- (NSString *)rowTitle
{
    return [[TSCStormLanguageController sharedController] localisedLanguageNameForLocaleIdentifier:self.videoLocaleString];
}

- (id)rowSelectionTarget
{
    return nil;
}

- (SEL)rowSelectionSelector
{
    return nil;
}

@end
