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

/**
 A subclass of ThunderBasic's `TSCLanguageController` which adds extra properties and methods to the controller more useful to Storm's needs
 */
@interface TSCStormLanguageController : TSCLanguageController

/**
 Returns the current shared instance of the `TSCStormLanguageController`.
 */
+ (TSCStormLanguageController *)sharedController;

/**
 Reloads the languages available to the app
 */
- (void)reloadLanguagePack;


/**
 Loads the language from a specific file for storm

 @param filePath The exact file path to load
 */
- (void)loadLanguageFile:(NSString *)filePath;

/**
 Returns a `NSLocale` for a storm language key
 @param localeString The locale string as returned by the CMS
 */
- (NSLocale *)localeForLanguageKey:(NSString *)localeString;

/**
 Returns a localised name for a language for a certain locale
 @param locale The locale to return the localised name for
 */
- (NSString *)localisedLanguageNameForLocale:(NSLocale *)locale;

/**
 Returns a localised name for a language for a certain locale identifier (i.e. en_US)
 @param localeIdentifier the locale id to return the localised name for
 */
- (NSString *)localisedLanguageNameForLocaleIdentifier:(NSString *)localeIdentifier;

/**
 Returns the locale for the users currently selected language
 */
- (NSLocale *)currentLocale;

/**
 Returns all available languages found in the current storm driven app
 @return An NSArray of TSCLanguage objects
 */
- (NSArray<TSCLanguage *> *)availableStormLanguages;

/**
 Confirms that the user wishes to switch the language to the current string set at as overrideLanguage
 */
- (void)confirmLanguageSwitch;

/**
 Returns the correct text alignment for the user's current language setting for a given base text direction. 
 @param textDirection the base text direction to correct for the users current language setting
 @discussion For example if the user has chosen "Arabic" as their language, if this method is sent `NSTextAlignmentLeft` it will return `NSTextAlignmentRight`
 */
- (NSTextAlignment)localisedTextDirectionForBaseDirection:(NSTextAlignment)textDirection;

/**
 Returns whether the users current language is a right to left language
 */
- (BOOL)isRightToLeft;

/**
 @abstract The users current selection of language
 @discussion This will be nil unless the user has specifically chosen a language which differs from the language their phone is currently in
 */
@property (nonatomic, strong) TSCLanguage *overrideLanguage;

/**
 @abstract The path to the languages folder in the phones file system
 */
@property (nonatomic, copy) NSString *languagesFolder;

/**
 @abstract The content controller which the language controller uses to access the bundle and observe changes to the bundle
 */
@property (nonatomic, strong) TSCContentController *contentController;

@end
