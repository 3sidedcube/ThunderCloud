//
//  TSCAuthenticationController.h
//  App Loader
//
//  Created by Matt Cheetham on 15/08/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@class TSCRequestController;
@import UIKit;

/**
 The Authentication Controller is responsible for authenticating with Storm endpoints. Any endpoint that requires an authorisation token can use this controller to obtain a token.
 */
@interface TSCAuthenticationController : NSObject

/**
 A block to be called when Storm authentication is completed
 */
typedef void (^TSCAuthenticationRequestCompletion)(BOOL sucessful, NSError *error);

/**
 The request controller that will make requests to the storm authorisation endpoints
 */
@property (nonatomic, strong) TSCRequestController *requestController;

/**
 The shared instance to be used for all authentication
 */
+ (TSCAuthenticationController *)sharedInstance;

/**
 Performs authorisation of a storm user, sending out notifications when the authorisation has completed
 @param username The Storm username to use for authentication
 @param password The storm password for the given user to use for authentication
 */
- (void)authenticateUsername:(NSString *)username password:(NSString *)password;

/**
 Performs authorisation of a storm user, calling a block upon completion
 @param username The Storm username to use for authentication
 @param password The storm password for the given user to use for authentication
 @param completion The block to call upon success or failure of authentication
 */
- (void)authenticateUsername:(NSString *)username password:(NSString *)password completion:(TSCAuthenticationRequestCompletion)completion;

/**
 @abstract Checks whether or not the authentication token has expired
 */
- (BOOL)isAuthenticated;

@end
