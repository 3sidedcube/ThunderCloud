//
//  TSCStormLanguageController.h
//  ThunderCloud
//
//  Created by Matt Cheetham on 04/03/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

@class TSCContentController;
@class TSCLanguage;

@import ThunderBasics;

@interface TSCStormLanguageController : TSCLanguageController

@property (nonatomic, copy) NSString *currentLanguage;
@property (nonatomic, strong) TSCLanguage *overrideLanguage;
@property (nonatomic, copy) NSString *currentLanguageShortKey;
@property (nonatomic, copy) NSString *languagesFolder;
@property (nonatomic, strong) TSCContentController *contentController;

+ (TSCStormLanguageController *)sharedController;
- (void)reloadLanguagePack;
- (NSLocale *)localeForLanguageKey:(NSString *)localeString;
- (NSString *)localisedLanguageNameForLocale:(NSLocale *)locale;
- (NSString *)localisedLanguageNameForLocaleIdentifier:(NSString *)localeIdentifier;
- (NSLocale *)currentLocale;

/**
 Returns all available languages found in the current storm driven app
 
 @return An NSArray of TSCLanguage objects
 
 **/
- (NSArray *)availableStormLanguages;

/**
 Confirms that the user wishes to switch the language to the current string set at as overrideLanguage
 **/
- (void)confirmLanguageSwitch;

- (NSTextAlignment)localisedTextDirectionForBaseDirection:(NSTextAlignment)textDirection;

- (BOOL)isRightToLeft;

@end
