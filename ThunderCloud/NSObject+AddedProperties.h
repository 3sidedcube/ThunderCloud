//
//  NSObject+AddedProperties.h
//  ThunderCloud
//
//  Created by Sam Houghton on 06/11/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (AddedProperties)

- (id)associativeObjectForKey: (NSString *)key;
- (void)setAssociativeObject: (id)object forKey: (NSString *)key;

@end
