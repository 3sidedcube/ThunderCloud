//
//  NSString+LocalisedString.m
//  ThunderCloud
//
//  Created by Matthew Cheetham on 16/09/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

#import "NSString+LocalisedString.h"
#import <objc/runtime.h>
#import "TSCStormLanguageController.h"
#import "TSCLocalisationController.h"
#import "NSObject+AddedProperties.h"

@import ThunderBasics;

@interface NSString (LocalisedStringPrivate)

@property (nonatomic, copy) NSString *localisationKey;

@end

NSString * const kLocalisationKeyPropertyKey = @"kLocalisationKey";

@implementation NSString (LocalisedString)

+ (instancetype)stringWithLocalisationKey:(NSString *)key
{
    NSString *currentLanguage = [[TSCStormLanguageController sharedController] currentLanguageShortKey];
    NSString *string = nil;
    
    if ([[TSCLocalisationController sharedController] localisationDictionaryForKey:key]) {
        
        NSDictionary *localisationDictionary = [[TSCLocalisationController sharedController] localisationDictionaryForKey:key];
        string = [NSString stringWithFormat:@"%@",localisationDictionary[currentLanguage]]; // There is a reason this is happening. It fixes a bug where these strings can't be higlighted for editing.
    } else {
        
        if ([[TSCStormLanguageController sharedController] stringForKey:key]) {
            string = [[TSCStormLanguageController sharedController] stringForKey:key];
        } else {
            string = key;
        }
    }
    
    string.localisationKey = key;
    return string;
}

+ (instancetype)stringWithLocalisationKey:(NSString *)key fallbackString:(NSString *)fallback
{
    NSString *currentLanguage = [[TSCStormLanguageController sharedController] currentLanguageShortKey];
    NSString *string = nil;
    
    if ([[TSCLocalisationController sharedController] localisationDictionaryForKey:key]) {
        
        NSDictionary *localisationDictionary = [[TSCLocalisationController sharedController] localisationDictionaryForKey:key];
        string = [NSString stringWithFormat:@"%@",localisationDictionary[currentLanguage]]; // There is a reason this is happening. It fixes a bug where these strings can't be higlighted for editing.
    } else {
        if ([[TSCStormLanguageController sharedController] stringForKey:key withFallbackString:fallback]) {
            string = [[TSCStormLanguageController sharedController] stringForKey:key withFallbackString:fallback];
        } else {
            string = fallback;
        }
    }
    
    string.localisationKey = key;
    return string;

}

+ (instancetype)stringWithLocalisationKey:(NSString *)key paramDictionary:(NSDictionary *)params
{
    __block NSString *localisedString = [NSString stringWithLocalisationKey:key];
    __block NSString *finalString = [NSString stringWithLocalisationKey:key];
    
//    localisedString = @"Call {EMERGENCY_NUMBER} to let {PERSON_NAME.capitalise()} know you're safe on {DATE.date(\"%d-%m-%Y\")}!";
    finalString = localisedString;
    
    NSRegularExpression *variableExpression = [NSRegularExpression regularExpressionWithPattern:@"\\{(.*?)\\}" options:kNilOptions error:nil];
    
    // Pulls out all parameters surrounded by {}
    [variableExpression enumerateMatchesInString:localisedString options:NSMatchingReportCompletion range:NSMakeRange(0, localisedString.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
       
        if (result) {
            
            NSString *fullMatch = [localisedString substringWithRange:result.range];
            
            NSArray *methods = [[localisedString substringWithRange:[result rangeAtIndex:1]] componentsSeparatedByString:@"."];
            __block NSString *variableKey = [localisedString substringWithRange:[result rangeAtIndex:1]];
            
            // If the parameter has methods attached to it then we need to perform these methods on the string before replacing it
            if (methods.count > 1) {
                
                variableKey = methods[0];
                __block NSString *paramString = params[variableKey];
                
                [methods enumerateObjectsUsingBlock:^(NSString *methodString, NSUInteger idx, BOOL *stop) {
                    
                    if (idx >= 1) {
                        paramString = [NSString performMethodWithString:methodString onParameter:paramString] ? : paramString;
                    }
                }];
                
                finalString = [finalString stringByReplacingCharactersInRange:[finalString rangeOfString:fullMatch] withString:paramString];
            } else {
            
                finalString = [finalString stringByReplacingCharactersInRange:[finalString rangeOfString:fullMatch] withString:params[variableKey]];
            }
        }
    
    }];
    
    return finalString;
}

// Performs a CMS localisation method on a string
+ (NSString *)performMethodWithString:(NSString *)methodString onParameter:(NSObject *)object
{
    NSString *methodizedString;
    NSArray *methodComponents = [methodString componentsSeparatedByString:@"("];
    
    if (methodComponents.count > 1) {
        
        // Gets the name of the method
        NSString *methodName = methodComponents[0];
        
        // Gets the remainder of the method so we can strip parameters
        NSString *methodRemainder = [methodString substringFromIndex:[methodString rangeOfString:methodName].location + [methodString rangeOfString:methodName].length];
        
        NSMutableArray *parameters = [NSMutableArray new];
        
        // Regex for pulling the parameters out of the method string
        NSRegularExpression *parametersExpression = [NSRegularExpression regularExpressionWithPattern:@"\"(.*?)\\\"" options:kNilOptions error:nil];
        [parametersExpression enumerateMatchesInString:methodRemainder options:kNilOptions range:NSMakeRange(0, methodRemainder.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
           
            [parameters addObject:[methodRemainder substringWithRange:[result rangeAtIndex:1]]];
        }];
        
        // Date method
        if ([methodName isEqualToString:@"date"] && [object isKindOfClass:[NSDate class]]) {
            
            if (parameters.count > 0) {
                methodizedString = [NSDateFormatter stringFromDate:(NSDate *)object withStrftimeFormat:parameters[0]];
            }
            return methodizedString;
        }
        
        // All string based methods
        if ([object isKindOfClass:[NSString class]]) {
            
            NSString *stringObject = (NSString *)object;
            NSLocale *currentLocale = [[TSCStormLanguageController sharedController] currentLocale];
            
            if ([methodName isEqualToString:@"uppercase"]) {
                
                methodizedString = [stringObject uppercaseStringWithLocale:currentLocale];
                
            } else if ([methodName isEqualToString:@"lowercase"]) {
                
                methodizedString = [stringObject lowercaseStringWithLocale:currentLocale];
                
            } else if ([methodName isEqualToString:@"capitalise"]) {
                
                methodizedString = [stringObject capitalizedStringWithLocale:currentLocale];
                
            } else if ([methodName isEqualToString:@"propercase"]) {
                
                // Lowercase to get rid of random uppercase letters
                stringObject = [stringObject lowercaseStringWithLocale:currentLocale];
                
                // Upper case otherwise full stop isn't picked up as the end of a sentecne
                NSString *testString = [stringObject uppercaseStringWithLocale:currentLocale];
                __block NSString *returnString = stringObject;
                [testString enumerateSubstringsInRange:NSMakeRange(0, stringObject.length) options:NSStringEnumerationBySentences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                   
                    returnString = [returnString stringByReplacingCharactersInRange:NSMakeRange(substringRange.location, 1) withString:[[substring substringToIndex:1] capitalizedString]];
                }];
                
                return returnString;
            }
            
            return methodizedString;
        }
    }
    
    return methodizedString;
}

#pragma mark - setters/getters

- (NSString *)localisationKey
{
    return [self associativeObjectForKey:@"localisationKey"];
}

- (void)setLocalisationKey:(NSString *)localisationKey
{
    [self setAssociativeObject:localisationKey forKey:@"localisationKey"];
}

@end
