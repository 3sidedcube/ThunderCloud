//
//  TSCLocalisationKeyValue.h
//  ThunderCloud
//
//  Created by Matthew Cheetham on 16/09/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

@import Foundation;
@import ThunderTable;

@interface TSCLocalisationKeyValue : NSObject

/**
 @abstract The short code that represents the language in the CMS (E.g. "en")
 */
@property (nonatomic, strong) NSString *languageCode;

/**
 @abstract The localised string for the assosicated language code
 */
@property (nonatomic, strong) NSString *localisedString;

@end
