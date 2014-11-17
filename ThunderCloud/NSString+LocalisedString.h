//
//  NSString+LocalisedString.h
//  ThunderCloud
//
//  Created by Matthew Cheetham on 16/09/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

@import Foundation;

@interface NSString (LocalisedString)

/**
    @abstract initialises a string using a localisation key.
    @param key The key for the localised string.
*/
+ (instancetype)stringWithLocalisationKey:(NSString *)key;

/**
 @abstract initialises a string using a localisation key, with a fallback if the string cannot be found.
 @param key The key for the localised string.
 @param fallback The string to fall back to if the key doesn't have a string value.
 */
+ (instancetype)stringWithLocalisationKey:(NSString *)key fallbackString:(NSString *)fallback;


/**
    @discussion Returns the key for the NSString, this can be nil-checked to see if a string is localised or not
*/
@property (nonatomic, strong, readonly) NSString *localisationKey;

@end
