//
//  TSCAuthenticationController.h
//  App Loader
//
//  Created by Matt Cheetham on 15/08/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@class TSCRequestController;
@import UIKit;

typedef void (^TSCAuthenticationRequestCompletion)(BOOL sucessful, NSError *error);

@interface TSCAuthenticationController : NSObject

@property (nonatomic, strong) TSCRequestController *requestController;

+ (TSCAuthenticationController *)sharedInstance;
- (void)authenticateUsername:(NSString *)username password:(NSString *)password;
- (void)authenticateUsername:(NSString *)username password:(NSString *)password completion:(TSCAuthenticationRequestCompletion)completion;

/**
 @abstract Checks whether or not the authentication token has expired
 */
- (BOOL)isAuthenticated;

@end
