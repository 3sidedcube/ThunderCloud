//
//  TSCLocalisationLanguage.h
//  ThunderCloud
//
//  Created by Matthew Cheetham on 17/09/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSCLocalisationLanguage : NSObject

/**
 @abstract A unique ID number that respresents the language in the CMS
 */
@property (nonatomic, strong) NSString *uniqueIdentifier;

/**
 @abstract The short code that represents the language in the CMS (E.g. "en")
 */
@property (nonatomic, strong) NSString *languageCode;

/**
 @abstract The localised language name for the given language, provided by the CMS
 */
@property (nonatomic, strong) NSString *languageName;

/**
 @abstract Whether or not the language has been published in the CMS
 */
@property (nonatomic, readwrite) BOOL isPublishable;


- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
