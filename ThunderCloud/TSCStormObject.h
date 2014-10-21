//
//  TSCStormObject.h
//  ThunderStorm
//
//  Created by Phillip Caudell on 23/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSCStormObjectDataSource.h"

@class TSCStormStyler;

@interface TSCStormObject : NSObject <TSCStormObjectDataSource>

@property (nonatomic, strong) NSMutableDictionary *overrides;
@property (nonatomic, strong) id parentObject;
@property (nonatomic, strong) TSCStormStyler *styler;

+ (TSCStormObject *)sharedController;
- (id)initWithDictionary:(NSDictionary *)dictionary DEPRECATED_ATTRIBUTE;
- (id)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject styler:(TSCStormStyler *)styler;
+ (id)objectWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject;
+ (void)overideClass:(Class)originalClass with:(Class)newClass;
+ (id)objectWithDictionary:(NSDictionary *)dictionary DEPRECATED_ATTRIBUTE;
- (void)overideClass:(Class)originalClass with:(Class)newClass DEPRECATED_ATTRIBUTE;
+ (Class)classForClassKey:(NSString *)key;

@end