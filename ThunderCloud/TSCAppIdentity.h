//
//  TSCAppIdentity.h
//  ThunderStorm
//
//  Created by Sam Houghton on 29/01/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSCAppIdentity : NSObject

@property (nonatomic, strong) NSString *appIdentifier;
@property (nonatomic, strong) NSString *iTunesId;
@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) NSString *launcher;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
