//
//  TSCLink.h
//  ThunderStorm
//
//  Created by Phillip Caudell on 10/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSCLink : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *linkClass;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSMutableArray *recipients;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *destination;
@property (nonatomic, strong) NSNumber *duration;
@property (nonatomic, strong) NSMutableArray *attributes;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (id)initWithURL:(NSURL *)URL;

@end
