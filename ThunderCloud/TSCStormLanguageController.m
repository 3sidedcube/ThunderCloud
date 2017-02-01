//
//  TSCStormLanguageController.m
//  ThunderCloud
//
//  Created by Matt Cheetham on 04/03/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import "TSCStormLanguageController.h"
#import "ThunderCloud/ThunderCloud-Swift.h"
#import "TSCLanguage.h"
#import "TSCBadgeController.h"
#import "ThunderCloud/ThunderCloud-Swift.h"

@implementation TSCStormLanguageController

static TSCStormLanguageController *sharedController = nil;

+ (TSCStormLanguageController *)sharedController
{
    return sharedController;
}

- (instancetype)init
{
    self = [super initWithDictionary:nil];
    
    if (self) {
        
        self.contentController = [TSCContentController shared];
        self.overrideLanguage = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"TSCLanguageOverride"]];
        
        sharedController = self;
    }
    
    return self;
}

#pragma mark - Storm language loading

- (void)reloadLanguagePack
{
    [self loadLanguageFile:[self languageFilePath]];
}

- (NSURL *)languageFilePath
{
    if(self.overrideLanguage){
        
        self.currentLanguage = self.overrideLanguage.languageIdentifier;
        
        if (self.currentLanguage) {
            NSURL *path = [self.contentController fileUrlForResource:self.overrideLanguage.languageIdentifier withExtension:@"json" inDirectory:@"languages"];
            if (path) {
                return path;
            }
        }
    }
    
    // Getting the user locale
    NSLocale *locale = [NSLocale currentLocale];
    
    NSString *localeString = [locale localeIdentifier];
    
    // Re-arranging it to match the language pack filename
    NSArray *localeComponents = [[localeString lowercaseString] componentsSeparatedByString:@"_"];
    
    if (localeComponents && localeComponents.count <= 1) {
        NSLog(@"Error getting locale components from %@", localeString);
        return nil;
    }
    
    /*
     * Load users preferred languages and iterate over each. checking all language packs for similarities and loading the closest match
     */
    NSArray *preferredLanguages = [NSLocale preferredLanguages];
    
    NSArray *availablePacks = [self.contentController filesInDirectory:@"languages"];
    
    NSString *englishFallbackPack = nil;
    
    //Compare preffered languages against available languages
    for (NSString *languageCode in preferredLanguages) {

        NSString *prefferedLanguageKey = [languageCode componentsSeparatedByString:@"-"].firstObject;
        
        for (NSString *availableLanguageFileName in availablePacks) {
            
            NSString *availableLanguageKey = [[availableLanguageFileName stringByDeletingPathExtension] componentsSeparatedByString:@"_"].lastObject;
            
            if ([availableLanguageKey isEqualToString:prefferedLanguageKey]) {
                
                self.currentLanguage = [availableLanguageFileName stringByDeletingPathExtension];
                self.currentLanguageShortKey = availableLanguageKey;
                
                NSURL *path = [self.contentController fileUrlForResource:self.currentLanguage withExtension:@"json" inDirectory:@"languages"];
                if (path) {
                    return path;
                }
                
            }
            
            //Add the english fallback
            if ([availableLanguageKey isEqualToString:@"en"]) {
                englishFallbackPack = [availableLanguageFileName stringByDeletingPathExtension];
            }
            
        }
        
    }
    
    //We've exhausted all combinations, go for the english fallback if available, if not, lucky dip!
    if (englishFallbackPack) {
        self.currentLanguage = englishFallbackPack;
        self.currentLanguageShortKey = [englishFallbackPack componentsSeparatedByString:@"_"].lastObject;
        NSURL *path = [self.contentController fileUrlForResource:self.currentLanguage withExtension:@"json" inDirectory:@"languages"];
        if (path) {
            return path;
        }
    }
    
    //There was no english pack so choose any language
    if (availablePacks.count > 0) {
        
        self.currentLanguage = [availablePacks.firstObject stringByDeletingPathExtension];
        self.currentLanguageShortKey = [self.currentLanguage componentsSeparatedByString:@"_"].lastObject;
        NSURL *path = [self.contentController fileUrlForResource:self.currentLanguage withExtension:@"json" inDirectory:@"languages"];
        if (path) {
            return path;
        }
    }
    
    // There are no languages in the language folder, at all
    return nil;
}

- (void)loadLanguageFile:(NSURL *)filePath
{
    if (filePath) {
        
        NSLog(@"<ThunderStorm> [Languages] Loading language at path %@", filePath);
        
        NSError *languageError;
        NSData *data = [NSData dataWithContentsOfURL:filePath options:NSDataReadingUncached error:&languageError];
        
        if (languageError || !data) {
            
            NSLog(@"<ThunderStorm> [Languages] No data for language pack");
            return;
        }
        
        NSDictionary *languageDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        self.languageDictionary = languageDictionary;
        
    } else {
        
        NSLog(@"<ThunderStorm> [Languages] File path was null");
        return;
    }
}


#pragma mark - Locale management

- (NSLocale *)localeForLanguageKey:(NSString *)localeString
{
    if (!localeString || [[localeString stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        return nil;
    }
    
    NSArray *localeComponents = [localeString componentsSeparatedByString:@"_"];
    NSLocale *locale;
    
    if (localeComponents.count == 0 || !localeComponents) {
        return nil;
    }
    
    if (localeComponents.count > 1) {
        locale = [NSLocale localeWithLocaleIdentifier:[NSLocale localeIdentifierFromComponents:@{NSLocaleLanguageCode: localeComponents.lastObject, NSLocaleCountryCode: localeComponents.firstObject}]];
    } else {
        locale = [NSLocale localeWithLocaleIdentifier:[NSLocale localeIdentifierFromComponents:@{NSLocaleLanguageCode: localeComponents.firstObject}]];
    }
    
    return locale;
}

- (NSString *)localisedLanguageNameForLocale:(NSLocale *)locale
{
    return [locale displayNameForKey:NSLocaleIdentifier value:locale.localeIdentifier];
}

- (NSString *)localisedLanguageNameForLocaleIdentifier:(NSString *)localeIdentifier
{
    return [self localisedLanguageNameForLocale:[self localeForLanguageKey:localeIdentifier]];
}

- (NSLocale *)currentLocale
{
    return [self localeForLanguageKey:self.currentLanguage];
}

- (NSString *)currentLanguageShortKey
{
    // Re-arranging it to match the language pack filename
    NSArray *localeComponents = [[self.currentLanguage lowercaseString] componentsSeparatedByString:@"_"];
    
    NSString *language;
    
    if (localeComponents && localeComponents.count > 1) {
        language = localeComponents.lastObject;
    }
    
    return language;
}

- (NSArray<TSCLanguage *> *)availableStormLanguages
{
    NSMutableArray *finalArray = [NSMutableArray array];
    
    for (NSString *language in [self.contentController filesInDirectory:@"languages"]){
        
        TSCLanguage *lang = [TSCLanguage new];
        lang.localisedLanguageName = [self localisedLanguageNameForLocaleIdentifier:language];
        lang.languageIdentifier = [language stringByDeletingPathExtension];
        
        BOOL alreadyExists = NO;
        
        for (TSCLanguage *addedLanguage in finalArray){
            
            if ([addedLanguage.languageIdentifier isEqualToString:[language stringByDeletingPathExtension]]) {
                alreadyExists = YES;
            }
        }
        
        if (!alreadyExists) {
            [finalArray addObject:lang];
        }
        
    }
    
    return finalArray;
}

#pragma mark - Language overriding

- (void)confirmLanguageSwitch
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.overrideLanguage] forKey:@"TSCLanguageOverride"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self reloadLanguagePack];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCStatEventNotification" object:self userInfo:@{@"type":@"event", @"category":@"Language Switching", @"action":[NSString stringWithFormat:@"Switch to %@", self.overrideLanguage.localisedLanguageName]}];
    
    [[TSCBadgeController sharedController] reloadBadgeData];
    
    // Re-index because we've changed language so we want core spotlight in correct language
    [[TSCContentController shared] indexAppContentWith:^(NSError *error) {
        
        // If we get an error mark the app as not indexed
        if (error) {
            
            [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"TSCIndexedInitialBundle"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
    
    TSCAppViewController *appView = [TSCAppViewController new];
    
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    keyWindow.rootViewController = appView;
}

#pragma mark - Right to left support

- (NSTextAlignment)localisedTextDirectionForBaseDirection:(NSTextAlignment)textDirection
{
    NSLocaleLanguageDirection languageDirection = [NSLocale characterDirectionForLanguage:[[TSCStormLanguageController sharedController].currentLocale objectForKey:NSLocaleLanguageCode]];
    
    if (textDirection == NSTextAlignmentLeft) {
        
        if (languageDirection == NSLocaleLanguageDirectionLeftToRight) {
            
            return NSTextAlignmentLeft;
            
        } else if (languageDirection == NSLocaleLanguageDirectionRightToLeft) {
            
            return NSTextAlignmentRight;
            
        }
        
    } else if (textDirection == NSTextAlignmentRight) {
        
        if (languageDirection == NSLocaleLanguageDirectionLeftToRight) {
            
            return NSTextAlignmentRight;
            
        } else if (languageDirection == NSLocaleLanguageDirectionRightToLeft) {
            
            return NSTextAlignmentLeft;
            
        }
    }
    
    return textDirection;
}

- (BOOL)isRightToLeft
{
    NSLocale *currentLocale = [[TSCStormLanguageController sharedController] currentLocale];
    
    if (currentLocale) {
        
        NSLocaleLanguageDirection languageDirection = [NSLocale characterDirectionForLanguage:[currentLocale objectForKey:NSLocaleLanguageCode]];
        
        if (languageDirection == NSLocaleLanguageDirectionRightToLeft) {
            return true;
        } else {
            return false;
        }
        
    } else {
        return false;
    }
}

@end
