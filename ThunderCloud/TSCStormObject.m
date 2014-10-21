//
//  TSCStormObject.m
//  ThunderStorm
//
//  Created by Phillip Caudell on 23/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCStormObject.h"
#import "TSCStormStyler.h"
#import <objc/runtime.h>

@implementation TSCStormObject

static TSCStormObject *sharedController = nil;

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        
    }
    
    return self;
}

+ (TSCStormObject *)sharedController
{
    @synchronized(self) {
        
        if (sharedController == nil) {
            
            sharedController = [[self alloc] init];
            sharedController.overrides = [NSMutableDictionary dictionary];
        }
    }
    
    return sharedController;
}

- (id)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject styler:(TSCStormStyler *)styler
{
    if (self = [super init]) {
        
        [self setStormParentObject:parentObject];
        [self setStormStyler:styler];
    }
    
    return self;
}

#pragma mark - Object creation

+ (id)objectWithDictionary:(NSDictionary *)dictionary
{
    return [TSCStormObject objectWithDictionary:dictionary parentObject:nil];
}

+ (id)objectWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject
{
    // Generate default class name
    NSString *className = [NSString stringWithFormat:@"TSC%@", dictionary[@"class"]];
    NSArray *attributes = dictionary[@"attributes"];
    TSCStormStyler *styler = nil;
    
    if (attributes) {
        styler = [TSCStormStyler stylerWithStormAttribute:[attributes firstObject]];
    } else {
        styler = [parentObject stormStyler];
    }
    
    // Select a class
    Class class = [TSCStormObject classFromClassName:className parentObject:parentObject styler:styler];

    // Create it
    id  <TSCStormObjectDataSource> object = nil;
    
    if ([class instancesRespondToSelector:@selector(initWithDictionary:parentObject:styler:)]) {
        object = [[class alloc] initWithDictionary:dictionary parentObject:parentObject styler:styler];
    } else {
        object = [[class alloc] initWithDictionary:dictionary];
    }

    if ([object respondsToSelector:@selector(setStormParentObject:)]) {
        [object setStormParentObject:parentObject];
    }

    return object;
}

#pragma mark - Class selection

+ (Class)classFromClassName:(NSString *)className parentObject:(id)parentObject styler:(TSCStormStyler *)styler
{
    Class originalClass = NSClassFromString(className);
    Class globalClass = [TSCStormObject globalClassOverideWithClassName:className];
    Class stylerClass = [styler classForClassName:className];
    
    // Styler classes can overide global classes. Styler classes are on a page by page basis
    if (stylerClass) {
        return stylerClass;
    }
 
    // Typical set at app startup
    if (globalClass) {
        return globalClass;
    }
    
    // Return default class
    return originalClass;
}

+ (Class)globalClassOverideWithClassName:(NSString *)className
{
    return [[TSCStormObject sharedController] overrides][className];
}

+ (Class)stylerClassOverideWithClassName:(NSString *)className parentObject:(id <TSCStormObjectDataSource>)parentObject
{
    TSCStormStyler *styler = [parentObject stormStyler];

    return [styler classForClassName:className];
}

#pragma mark - Storm object data source

- (id)stormParentObject
{
    return self.parentObject;
}

- (void)setStormParentObject:(id)parentObject
{
    self.parentObject = parentObject;
}

- (TSCStormStyler *)stormStyler
{
    return self.styler;
}

- (void)setStormStyler:(TSCStormStyler *)styler
{
    self.styler = styler;
}

#pragma mark - Old

+ (Class)classForClassKey:(NSString *)key
{
    if ([TSCStormObject sharedController].overrides[key]) {
        return[TSCStormObject sharedController].overrides[key];
    } else {
        return NSClassFromString(key);
    }
}

+ (Class)classFromClassName:(NSString *)className
{
    return [self classFromClassName:className parentObject:nil styler:nil];
}

- (void)overideClass:(Class)originalClass with:(Class)newClass
{
    [self.overrides setObject:newClass forKey:NSStringFromClass(originalClass)];
}

+ (void)overideClass:(Class)originalClass with:(Class)newClass
{
    [[[TSCStormObject sharedController] overrides] setObject:newClass forKey:NSStringFromClass(originalClass)];
}

@end
