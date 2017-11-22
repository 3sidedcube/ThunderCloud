////
////  TSCLocalisationController.h
////  ThunderCloud
////
////  Created by Matthew Cheetham on 16/09/2014.
////  Copyright (c) 2014 threesidedcube. All rights reserved.
////
//
//#import <Foundation/Foundation.h>
//#import "UIWindow+TSCWindow.h"
//
//// An enum which defines an activation
//typedef NS_ENUM(NSUInteger, TSCLocalisationActivation) {
//    
//    // No event will cause activation, you must call `toggleEditing` to toggle editing on/off
//    TSCLocalisationActivationNone = 0,
//    // Shake the device to enable localisation editing
//    TSCLocalisationActivationShake = 1,
//    //  Take a screenshot to enable localisation editing
//    TSCLocalisationActivationScreenshot = 2,
//    //  Swipe left with two fingers to enable localisation editing
//    TSCLocalisationActivationTwoFingersSwipeLeft = 3
//};
//
//@class Localisation, LocalisationLanguage;
//
///**
// A Controller for managing CMS localisations
// @discussion Can be used to fetch localisations from the current CMS, Update localisations on the CMS, discover available languages in the CMS.
// */
//@interface TSCLocalisationController : NSObject
//
///**
// A completion block to be fired when localisations have been returned from the CMS
// */
////typedef void (^TSCLocalisationFetchCompletion)(NSArray <Localisation *> *localisations, NSError *error);
////
/////**
//// A completion block to be fired when a save operation has been performed on the CMS
//// */
////typedef void (^TSCLocalisationSaveCompletion)(NSError *error);
////
/////**
//// A completion block to be fired when languages have been returned from the CMS
//// */
////typedef void (^TSCLocalisationFetchLanguageCompletion)(NSArray *languages, NSError *error);
////
/////**
//// @abstract Defines if the the user is currently editing localisations
//// */
////@property (nonatomic, readwrite) BOOL editing;
////
/////**
//// @abstract Defines how the user can activate localisation editing
//// @discussion By default this is set to a shake gesture
//// */
////@property (nonatomic, assign) TSCLocalisationActivation activationMode;
////
/////**
//// @abstract An array of available languages, populated from the CMS.
//// */
////@property (nonatomic, strong) NSArray <LocalisationLanguage *> *availableLanguages;
////
/////**
//// @abstract An array of all the edited localisations, which is cleared every time you save them to the CMS
//// */
////@property (nonatomic, strong, readonly) NSMutableArray *editedLocalisations;
////
/////**
//// @abstract An array of localisations which weren't picked up on when view highlighting occured
//// */
////@property (nonatomic, strong, readonly) NSMutableArray *additionalLocalisedStrings;
////
/////**
//// Returns the currently initiated shared `TSCLocalisationController`
//// */
////+ (TSCLocalisationController *)sharedController;
////
/////**
//// @abstract Updates the localisation strings from the server
//// @param completion The completion block to be called when all localisations have been fetched from the server
//// */
////- (void)fetchLocalisations:(TSCLocalisationFetchCompletion)completion;
////
/////**
//// @abstract Saves all edited localisations to the server
//// @param completion The completion block to be called when the localisations have saved
//// */
////- (void)saveLocalisations:(TSCLocalisationSaveCompletion)completion;
////
/////**
//// @abstract Updates the apps available languages from the CMS
//// @param completion The completion block to be called when the localisations have saved
//// */
////- (void)fetchAvailableLanguagesForApp:(TSCLocalisationFetchLanguageCompletion)completion;
////
/////**
//// @abstract Enables or disables editing mode for the current view
//// */
////- (void)toggleEditing;
////
/////**
//// @abstract Registers a localisation to be saved to CMS. This method adds the TSCLocalisation to self.editedLocalisations if it not already in there.
//// @param localisation The localisations to be registered as edited.
//// */
////- (void)registerLocalisationEdited:(Localisation *)localisation;
////
/////**
//// @abstract Looks up the human readable language name for a code in the CMS's configured languages
//// @param key The language key to be used when looking up the localised language name
//// */
////- (NSString *)localisedLanguageNameForLanguageKey:(NSString *)key;
////
/////**
//// @abstract Returns a language object for a CMS language code
//// @param key The language key to be used when looking up the language
//// */
////- (LocalisationLanguage *)languageForLanguageKey:(NSString *)key;
////
/////**
//// @abstract If the user has edited strings in the CMS this will return the string they have saved
//// @param key The localisation key to be used to find the readable string
//// */
////- (NSDictionary *)localisationDictionaryForKey:(NSString *)key;
////
/////**
//// @abstract Returns the CMS localisation for a localisation key
//// @param key The key to return a localisation for
//// */
////- (Localisation *)CMSLocalisationForKey:(NSString *)key;
//
//
//@end

