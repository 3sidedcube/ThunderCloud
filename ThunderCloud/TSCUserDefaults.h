//
//  TSCUserDefaults.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 09/10/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSCUserDefaults : NSObject

@property (nonatomic, strong) NSMutableDictionary *defaults;

- (id)objectForKey:(NSString *)key;
- (void)setObject:(id)object forKey:(NSString *)key;

+ (TSCUserDefaults *)sharedController;

@end
