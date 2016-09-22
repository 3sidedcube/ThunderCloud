//
//  TSCLink.h
//  ThunderStorm
//
//  Created by Phillip Caudell on 10/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 `TSCLink` is an object representation of a URL. This url can be a reference to a storm page, a website, details of an SMS, email and various other types.
 
 Navigating between storm views is best handled using `TSCLink`
 */
@interface TSCLink : NSObject

///---------------------------------------------------------------------------------------
/// @name Initializing a TSCLink
///---------------------------------------------------------------------------------------

/**
 Initializes a TSCLink
 @param url The NSURL that you intend to push the user to
 */
- (id _Nullable)initWithURL:(NSURL * _Nonnull)URL;

/**
 Initializes a TSCLink
 @param dictionary A TSCLink dictionary that you intend to push the user to
 @discussion This dictionary can be found inside Storm's JSON files.
 */
- (id _Nullable)initWithDictionary:(NSDictionary * _Nonnull)dictionary;

/**
 Initializes a TSCLink to a storm page
 @param stormPageId The storm page ID
 */
- (id _Nullable)initWithStormPageId:(NSString * _Nonnull)stormPageId;

/**
 Initializes a TSCLink to a storm page
 @param stormPageName The storm page name
 */
- (id _Nullable)initWithStormPageName:(NSString * _Nonnull)stormPageName;

///---------------------------------------------------------------------------------------
/// @name Standard link properties
///---------------------------------------------------------------------------------------

/**
 @abstract The title to describe the link
 */
@property (nonatomic, copy) NSString * _Nullable title;

/**
 @abstract The URL given to the object after initialization
 */
@property (nonatomic, strong) NSURL * _Nullable url;

/**
 @abstract The type of link
 @discussion Storm has various link types for different link behaviours. They are represented as different objects in Storm but ultimately are represented by the same model in this iOS libary
 */
@property (nonatomic, copy) NSString * _Nullable linkClass;

///---------------------------------------------------------------------------------------
/// @name SMS & Email Links
///---------------------------------------------------------------------------------------

/**
 @abstract The body of text to be shared
 @discussion Email and SMS links contain this body
 */
@property (nonatomic, copy) NSString * _Nullable body;

/**
 @abstract An array of recipients that the body should be shared to
 @discussion This property is only used by the SMS style link
 */
@property (nonatomic, strong) NSMutableArray * _Nullable recipients;

///---------------------------------------------------------------------------------------
/// @name Inter-app linking
///---------------------------------------------------------------------------------------

/**
 @abstract The unique identifier of the App as represented in the indentifiers.json
 @discussion This is only used for inter-app linking
 */
@property (nonatomic, copy) NSString * _Nullable identifier;

/**
 @abstract The URL to be passed to the recieving app
 @discussion This is only used for inter-app linking
 */
@property (nonatomic, copy) NSString * _Nullable destination;

///---------------------------------------------------------------------------------------
/// @name Timer Links
///---------------------------------------------------------------------------------------

/**
 @abstract An NSNumber representation of the number of seconds the timer should run for
 @discussion A TimerLink object uses this property
 */
@property (nonatomic, strong) NSNumber * _Nullable duration;

///---------------------------------------------------------------------------------------
/// @name Miscellaneous properties
///---------------------------------------------------------------------------------------

/**
 @abstract An array of additional attributed for the link
 @discussion This array can contain any number of properties which may be useful when representing custom content
 */
@property (nonatomic, strong) NSMutableArray * _Nullable attributes;

@end
