//
//  TSCAppLinkController.h
//  ThunderStorm
//
//  Created by Sam Houghton on 29/01/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSCAppIdentity.h"

@interface TSCAppLinkController : NSObject

@property (nonatomic, strong) NSMutableArray *identifiers;

+ (TSCAppLinkController *)sharedController;

- (TSCAppIdentity *)appForId:(NSString *)appId;

@end
