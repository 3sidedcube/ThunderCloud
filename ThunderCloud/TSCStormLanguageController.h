//
//  TSCStormLanguageController.h
//  ThunderCloud
//
//  Created by Matt Cheetham on 04/03/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

@class TSCContentController;
@import ThunderBasics;

@interface TSCStormLanguageController : TSCLanguageController

@property (nonatomic, strong) NSString *currentLanguage;
@property (nonatomic, strong) NSString *languagesFolder;
@property (nonatomic, strong) TSCContentController *contentController;

+ (TSCStormLanguageController *)sharedController;
- (void)reloadLanguagePack;
- (NSLocale *)localeForLanguageKey:(NSString *)localeString;
- (NSString *)localisedLanguageNameForLocale:(NSLocale *)locale;
- (NSString *)localisedLanguageNameForLocaleIdentifier:(NSString *)localeIdentifier;
- (NSLocale *)currentLocale;

@end
