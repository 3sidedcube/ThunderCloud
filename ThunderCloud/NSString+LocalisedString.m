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

- (instancetype)stringWithLocalisationKey:(NSString *)key
{
    NSString *currentLanguage = [[TSCStormLanguageController sharedController] currentLanguageShortKey];
    NSString *string = nil;
    
    if ([[TSCLocalisationController sharedController] localisationDictionaryForKey:key]) {
        
        NSDictionary *localisationDictionary = [[TSCLocalisationController sharedController] localisationDictionaryForKey:key];
        string = [NSString stringWithFormat:@"%@",localisationDictionary[currentLanguage]]; // There is a reason this is happening. It fixes a bug where these strings can't be higlighted for editing.
    } else {
        
        if ([[TSCStormLanguageController sharedController] stringForKey:key withFallbackString:self]) {
            string = [[TSCStormLanguageController sharedController] stringForKey:key withFallbackString:self];
        } else {
            string = self;
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
    return (NSString *)[NSString objectWithLocalisationKey:key paramDictionary:params class:[NSString class]];
}

+ (NSAttributedString *)attributedStringWithLocalisationKey:(NSString *)key paramDictionary:(NSDictionary *)params
{
    return (NSAttributedString *)[NSString objectWithLocalisationKey:key paramDictionary:params class:[NSAttributedString class]];
}

+ (NSObject *)objectWithLocalisationKey:(NSString *)key paramDictionary:(NSDictionary *)params class:(Class)class
{
    __block NSString *localisedString = [NSString stringWithLocalisationKey:key];
    __block NSObject *finalString = (class == [NSString class]) ? [NSString stringWithLocalisationKey:key] : [[NSAttributedString alloc] initWithString:[NSString stringWithLocalisationKey:key]];
    
    //    localisedString = @"The date is {DATE.date(\"%Y-%m-%d\").underline(\"#F00\",\"1\").textcolor(\"#F00\")}!"; // For testing
    //    finalString = (class == [NSString class]) ? localisedString : [[NSAttributedString alloc] initWithString:localisedString];
    
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
                __block NSObject *paramString = params[variableKey];
                
                // Perform any methods found on variable to customise the string
                [methods enumerateObjectsUsingBlock:^(NSString *methodString, NSUInteger idx, BOOL *stop) {
                    
                    if (idx >= 1) {
                        
                        paramString = [NSString performMethodWithString:methodString onParameter:paramString class:class] ? : paramString;
                    }
                }];
                
                if (paramString) {
                    
                    if (class == [NSString class]) {
                        finalString = [((NSString *)finalString) stringByReplacingCharactersInRange:[((NSString *)finalString) rangeOfString:fullMatch] withString:(NSString *)paramString];
                    } else {
                        
                        // Cast the returned replacement for variable to an NSAttributedString
                        NSAttributedString *attributedParamString = (NSAttributedString *)paramString;
                        // Create mutable copy of the currently processed string
                        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:(NSAttributedString *)finalString];
                        // Replace the variable with the attributed string calculated by +performMethodWithString:onParameter:class
                        [attributedString replaceCharactersInRange:[((NSAttributedString *)finalString).string rangeOfString:fullMatch] withAttributedString:attributedParamString];
                        finalString = attributedString;
                    }
                }
            } else {
                
                NSObject *parameter = params[variableKey];
                
                if ([parameter isKindOfClass:[NSString class]]) {
                    
                    if (class == [NSString class]) {
                        
                        finalString = [((NSString *)finalString) stringByReplacingCharactersInRange:[((NSString *)finalString) rangeOfString:fullMatch] withString:params[variableKey]];
                        
                    } else {
                        
                        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:(NSAttributedString *)finalString];
                        [attributedString replaceCharactersInRange:[((NSAttributedString *)finalString).string rangeOfString:fullMatch] withString:params[variableKey]];
                        finalString = [attributedString copy];
                    }
                }
            }
        }
        
    }];
    
    return finalString;
}

// Performs a CMS localisation method on a string
+ (NSObject *)performMethodWithString:(NSString *)methodString onParameter:(NSObject *)object class:(Class)class
{
    NSObject *methodizedString;
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
            
            if (class == [NSAttributedString class]) {
                methodizedString = [[NSAttributedString alloc] initWithString:(NSString *)methodizedString];
            }
            
            return methodizedString;
        }
        
        // All string based methods
        if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSAttributedString class]]) {
            
            methodizedString = (NSString *)object;
            NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
            
            if ([object isKindOfClass:[NSAttributedString class]]) {
                
                NSRange range = NSMakeRange(0, 1);
                attributes = [[((NSAttributedString *)methodizedString) attributesAtIndex:0 effectiveRange:&range] mutableCopy];
                methodizedString = ((NSAttributedString *)methodizedString).string;
            }
            
            methodizedString = [NSString performStringMethod:methodName withParameters:parameters onString:(NSString *)methodizedString];

            if (class == [NSAttributedString class]) {
                
                [attributes addEntriesFromDictionary:[NSString attributeDictionaryWithMethod:methodName withParameters:parameters]];
                methodizedString = [[NSAttributedString alloc] initWithString:(NSString *)methodizedString attributes:attributes];
            }
            
            return methodizedString;
        }
    }
    
    return methodizedString;
}

// Method for mutating a string given a method name + parameters
+ (NSString *)performStringMethod:(NSString *)methodName withParameters:(NSArray *)parameters onString:(NSString *)string
{
    if (methodName && [methodName isKindOfClass:[NSString class]]) {
        
        NSLocale *currentLocale = [[TSCStormLanguageController sharedController] currentLocale];
        
        if ([methodName isEqualToString:@"uppercase"]) {
            
            string = [string uppercaseStringWithLocale:currentLocale];
            
        } else if ([methodName isEqualToString:@"lowercase"]) {
            
            string = [string lowercaseStringWithLocale:currentLocale];
            
        } else if ([methodName isEqualToString:@"capitalise"]) {
            
            string = [string capitalizedStringWithLocale:currentLocale];
            
        } else if ([methodName isEqualToString:@"propercase"]) {
            
            // Lowercase to get rid of random uppercase letters
            string = [string lowercaseStringWithLocale:currentLocale];
            
            // Upper case otherwise full stop isn't picked up as the end of a sentecne
            NSString *testString = [(NSString *)string uppercaseStringWithLocale:currentLocale];
            __block NSString *returnString = (NSString *)string;
            [testString enumerateSubstringsInRange:NSMakeRange(0, string.length) options:NSStringEnumerationBySentences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                
                returnString = [returnString stringByReplacingCharactersInRange:NSMakeRange(substringRange.location, 1) withString:[[substring substringToIndex:1] capitalizedString]];
            }];

            return returnString;
        }
    }
    
    return string;
}

// Method for creating attributes dictionary with method and parameters
+ (NSDictionary *)attributeDictionaryWithMethod:(NSString *)methodName withParameters:(NSArray *)parameters
{
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    
    if ([methodName isEqualToString:@"textcolor"]) {
        
        if ([UIColor colorWithHexString:[parameters firstObject]]) {
            attributes[NSForegroundColorAttributeName] = [UIColor colorWithHexString:[parameters firstObject]];
        }
    } else if ([methodName isEqualToString:@"backgroundcolor"]) {
        
        if ([UIColor colorWithHexString:[parameters firstObject]]) {
            attributes[NSBackgroundColorAttributeName] = [UIColor colorWithHexString:[parameters firstObject]];
        }
    } else if ([methodName isEqualToString:@"underline"]) {
        
        for (NSString *parameter in parameters) {
            
            if ([UIColor colorWithHexString:(NSString *)parameter]) {
                attributes[NSUnderlineColorAttributeName] = [UIColor colorWithHexString:(NSString *)parameter];
            } else {
                attributes[NSUnderlineStyleAttributeName] = @([parameter integerValue]);
            }
        }
        
    } else if ([methodName isEqualToString:@"strikethrough"]) {
        
        attributes[NSStrikethroughStyleAttributeName] = @(NSUnderlineStyleSingle);
        
        for (NSString *parameter in parameters) {
            
            if ([UIColor colorWithHexString:(NSString *)parameter]) {
                attributes[NSStrikethroughColorAttributeName] = [UIColor colorWithHexString:(NSString *)parameter];
            } else {
                attributes[NSStrikethroughStyleAttributeName] = @([parameter integerValue]);
            }
        }
    } else if ([methodName isEqualToString:@"stroke"]) {
        
        attributes[NSStrokeWidthAttributeName] = @(1);
        
        for (NSString *parameter in parameters) {
            
            if ([UIColor colorWithHexString:(NSString *)parameter]) {
                attributes[NSStrokeColorAttributeName] = [UIColor colorWithHexString:(NSString *)parameter];
            } else {
                attributes[NSStrokeWidthAttributeName] = @([parameter doubleValue]);
            }
        }
    } else if ([methodName isEqualToString:@"skew"]) {
        
        attributes[NSObliquenessAttributeName] = @([[parameters firstObject] doubleValue]);
    }
    
    return attributes;
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
