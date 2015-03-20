//
//  TSCAppLinkController.h
//  ThunderStorm
//
//  Created by Sam Houghton on 29/01/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSCAppIdentity.h"

/**
 `TSCAppLinkController` is a controller for linking between different apps on the users phone. It creates an array of `TSCAppIdentity`s out of the content controller when first initialised.
 
 */
@interface TSCAppLinkController : NSObject

@property (nonatomic, strong) NSMutableArray *identifiers;

/**
 Returns a shared instance of `TSCAppLinkController`
 */
+ (TSCAppLinkController *)sharedController;

/**
 Returns a `TSCAppIdentity` for a given id
 @param appId The id for the given app
 */
- (TSCAppIdentity *)appForId:(NSString *)appId;

@end
