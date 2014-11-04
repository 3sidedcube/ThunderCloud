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
    @abstract initialises a string using a localisation key
    @param key the key for the localised string
*/
+ (instancetype)stringWithLocalisationKey:(NSString *)key;

/**
    @discussion Returns the key for the NSString, this can be nil-checked to see if a string is localised or not
*/
@property (nonatomic, strong, readonly) NSString *localisationKey;

@end
