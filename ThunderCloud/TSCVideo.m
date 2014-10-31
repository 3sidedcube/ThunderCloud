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

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
    
        self.videoLocale = dictionary[@"locale"];
        self.videoLink = [[TSCLink alloc] initWithDictionary:dictionary[@"src"]];
        
        [[TSCStormLanguageController sharedController] localeForLanguageKey:self.videoLocale];
    }
    
    return self;
}

- (NSString *)rowTitle
{
    return [[TSCStormLanguageController sharedController] localisedLanguageNameForLocaleIdentifier:self.videoLocale];
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
