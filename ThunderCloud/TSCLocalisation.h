//
//  TSCLocalisation.h
//  ThunderCloud
//
//  Created by Matthew Cheetham on 16/09/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

@import Foundation;

/**
 A class representation of a STORM CMS localisation object
 */
@interface TSCLocalisation : NSObject

/**
 @abstract The localisation key that represents the string in the CMS (e.g. "_TEST_DONE_BUTTON_TEXT")
 */
@property (nonatomic, strong) NSString *localisationKey;

/**
 @abstract An array of TSCLocalisationKeyValue objects that represent the value for each language for the given key
 */
@property (nonatomic, strong) NSArray *localisationValues;

/**
 @abstract Initializes a `TSCLocalisation` object from a dictionary
 @param dictionary A dictionary representing a CMS localisation object
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 @abstract sets the localised string for a particular language code
 @param localisedString The localised string to be set
 @param string The language code to set the string for
 */
- (void)setLocalisedString:(NSString *)localisedString forLanguageCode:(NSString *)string;

/**
 @abstract serialises the localised string to a dictionary which can be sent to the storm API
 */
- (NSDictionary *)serialisableRepresentation;

/**
 @abstract creates a new instance of `TSCLocalisation` with no strings set for any language
 @param languages An array of `TSCLocalisationLanguage` objects
 */
- (instancetype)initWithAvailableLanguages:(NSArray *)languages;

@end
