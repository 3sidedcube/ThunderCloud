//
//  TSCAppIdentity.h
//  ThunderStorm
//
//  Created by Sam Houghton on 29/01/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSCAppIdentity : NSObject

@property (nonatomic, copy) NSString *appIdentifier;
@property (nonatomic, copy) NSString *iTunesId;
@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, copy) NSString *launcher;
@property (nonatomic, copy) NSString *appName;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
