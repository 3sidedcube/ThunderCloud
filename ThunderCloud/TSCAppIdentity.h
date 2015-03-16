//
//  TSCAppIdentity.h
//  ThunderStorm
//
//  Created by Sam Houghton on 29/01/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 `TSCAppIdentity` is a model representation of an app to link to.
 */
@interface TSCAppIdentity : NSObject

/**
 @abstract The unique identifier for the app
 */
@property (nonatomic, copy) NSString *appIdentifier;

/**
 @abstract The iTunes id of the app
 */
@property (nonatomic, copy) NSString *iTunesId;

/**
 @abstract The apps iTunes country code
 */
@property (nonatomic, copy) NSString *countryCode;

/**
 @abstract The launcher url for that app
 @discussion It can be used to check if the app exists on the phone and can then be used to link the user into it
 */
@property (nonatomic, copy) NSString *launcher;

/**
 @abstract The apps name
 */
@property (nonatomic, copy) NSString *appName;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
