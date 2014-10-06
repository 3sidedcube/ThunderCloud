//
//  TSCStormStyler.h
//  ThunderCloud
//
//  Created by Phillip Caudell on 08/04/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSCStormStyler : NSObject

+ (id)stylerWithStormAttribute:(NSString *)attribute;
+ (Class)stylerClassForStormAttribute:(NSString *)attribute;
- (void)overideClass:(Class)originalClass with:(Class)newClass;
- (Class)classForClassName:(NSString *)className;

@end
