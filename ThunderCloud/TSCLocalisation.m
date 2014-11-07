//
//  TSCLocalisation.m
//  ThunderCloud
//
//  Created by Matthew Cheetham on 16/09/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

#import "TSCLocalisation.h"
#import "TSCLocalisationKeyValue.h"
#import "TSCLocalisationLanguage.h"

@implementation TSCLocalisation

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        
        NSMutableArray *tempValues = [NSMutableArray array];
        for (NSString *languageKey in dictionary.allKeys) {
            
            TSCLocalisationKeyValue *localisationKeyValue = [TSCLocalisationKeyValue new];
            localisationKeyValue.languageCode = languageKey;
            localisationKeyValue.localisedString = dictionary[languageKey];
            [tempValues addObject:localisationKeyValue];
        }
        
        self.localisationValues = tempValues;
        
    }
    
    return self;
}

- (instancetype)initWithAvailableLanguages:(NSArray *)languages
{
    if (self = [super init]) {
        
        NSMutableArray *tempValues = [NSMutableArray array];
        
        for (TSCLocalisationLanguage *language in languages) {
            
            TSCLocalisationKeyValue *localisationKeyValue = [TSCLocalisationKeyValue new];
            localisationKeyValue.languageCode = language.languageCode;
            localisationKeyValue.localisedString = @"";
            [tempValues addObject:localisationKeyValue];
        }
        
        self.localisationValues = tempValues;
    }
    
    return self;
}

- (void)setLocalisedString:(NSString *)localisedString forLanguageCode:(NSString *)string
{
    [self.localisationValues enumerateObjectsUsingBlock:^(TSCLocalisationKeyValue *localisationKeyValue, NSUInteger idx, BOOL *stop){
        
        if ([localisationKeyValue.languageCode isEqualToString:string]) {
            
            localisationKeyValue.localisedString = localisedString;
            *stop = YES;
        }
    }];
}

- (NSDictionary *)serialisableRepresentation
{
    NSMutableDictionary *languageDictionary = [NSMutableDictionary new];
    
    for (TSCLocalisationKeyValue *localisationKeyValue in self.localisationValues) {
        
        languageDictionary[localisationKeyValue.languageCode] = localisationKeyValue.localisedString;
    }
    
    return languageDictionary;
}

@end
