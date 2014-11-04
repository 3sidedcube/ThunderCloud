//
//  TSCLocalisationController.h
//  ThunderCloud
//
//  Created by Matthew Cheetham on 16/09/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIWindow+TSCWindow.h"

@class TSCLocalisation;
@interface TSCLocalisationController : NSObject

typedef void (^TSCLocalisationFetchCompletion)(NSArray *localisations, NSError *error);
typedef void (^TSCLocalisationSaveCompletion)(NSError *error);
typedef void (^TSCLocalisationFetchLanguageCompletion)(NSArray *languages, NSError *error);
typedef void (^TSCLocalisationRefreshCompletion)(NSError *error);

/**
 @abstract Defines if the the user is currently editing localisations
 */
@property (nonatomic, readwrite) BOOL editing;

/**
 @abstract An array of available languages, populated from the CMS.
 */
@property (nonatomic, strong) NSArray *availableLanguages;

/**
 @abstract An array of all the edited localisations, which is cleared every time you save them to the CMS
 */
@property (nonatomic, readonly) NSMutableArray *editedLocalisations;

+ (TSCLocalisationController *)sharedController;

/**
 @abstract Updates the localisation strings from the server
 @param completion The completion block to be called when all localisations have been fetched from the server
 */
- (void)fetchLocalisations:(TSCLocalisationFetchCompletion)completion;

/**
 @abstract Saves all edited localisations to the server
 @param completion The completion block to be called when the localisations have saved
 */
- (void)saveLocalisations:(TSCLocalisationSaveCompletion)completion;

/**
 @abstract Updates the apps available languages from the CMS
 @param completion The completion block to be called when the localisations have saved
 */
- (void)fetchAvailableLanguagesForApp:(TSCLocalisationFetchLanguageCompletion)completion;

/**
 @abstract Enables or disables editing mode for the current view
 */
- (void)toggleEditing;

/**
 @abstract Registers a localisation to be saved to CMS. This method adds the TSCLocalisation to self.editedLocalisations if it not already in there.
 @param localisation The localisations to be registered as edited.
 */
- (void)registerLocalisationEdited:(TSCLocalisation *)localisation;

/**
 @abstract Looks up the human readable language name for a code in the CMS's configured languages
 @param key The language key to be used when looking up the localised language name
 */
- (NSString *)localisedLanguageNameForLanguageKey:(NSString *)key;

/**
 @abstract If the user has edited strings in the CMS this will return the string they have saved
 @param key The localisation key to be used to find the readable string
 */
- (NSDictionary *)localisationDictionaryForKey:(NSString *)key;

@end
