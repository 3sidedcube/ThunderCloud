//
//  NSString+LocalisedString.m
//  ThunderCloud
//
//  Created by Matthew Cheetham on 16/09/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

#import "NSString+LocalisedString.h"
#import "TSCLocalisationController.h"
#import "TSCStormLanguageController.h"
#import <objc/runtime.h>

@import ThunderBasics;

@interface NSString (LocalisedStringPrivate)

@property (nonatomic, strong, readwrite) NSString *localisationKey;

@end

@implementation NSString (LocalisedString)

+ (instancetype)stringWithLocalisationKey:(NSString *)key
{
    
    NSString *currentLanguage = [[TSCStormLanguageController sharedController] currentLanguageShortKey];
    NSString *string = nil;
    
    if ([[TSCLocalisationController sharedController] localisationDictionaryForKey:key]) {
        
        NSDictionary *localisationDictionary = [[TSCLocalisationController sharedController] localisationDictionaryForKey:key];
        string = [NSString stringWithFormat:@"%@",localisationDictionary[currentLanguage]]; // There is a reason this is happening. It fixes a bug where these strings can't be higlighted for editing.
    } else {
        string = TSCLanguageString(key);
    }
    string.localisationKey = key;
    
    return string ? string : key;
}

#pragma mark - setters/getters

- (NSString *)localisationKey
{
    return objc_getAssociatedObject(self, @selector(localisationKey));
}

- (void)setLocalisationKey:(NSString *)localisationKey
{
    objc_setAssociatedObject(self, @selector(localisationKey), localisationKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
