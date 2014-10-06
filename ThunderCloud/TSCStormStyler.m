//
//  TSCStormStyler.m
//  ThunderCloud
//
//  Created by Phillip Caudell on 08/04/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import "TSCStormStyler.h"

@interface TSCStormStyler()

@property (nonatomic, strong) NSMutableDictionary *overides;

@end

@implementation TSCStormStyler

+ (id)stylerWithStormAttribute:(NSString *)attribute
{
    Class stylerClass = [TSCStormStyler stylerClassForStormAttribute:attribute];
    TSCStormStyler *styler = [stylerClass new];
    
    return styler;
}

+ (Class)stylerClassForStormAttribute:(NSString *)attribute
{
    if ([attribute isEqualToString:@"STYLE_PAPER"]) {
        return NSClassFromString(@"RCPaperStormStyler");
    }
    
    return nil;
}

- (void)overideClass:(Class)originalClass with:(Class)newClass
{
    if (!self.overides) {
        self.overides = [NSMutableDictionary dictionary];
    }
    
    self.overides[NSStringFromClass(originalClass)] = newClass;
}

- (Class)classForClassName:(NSString *)className
{
    return self.overides[className];
}

@end
