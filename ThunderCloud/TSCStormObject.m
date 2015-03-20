//
//  TSCStormObject.m
//  ThunderStorm
//
//  Created by Phillip Caudell on 23/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCStormObject.h"
#import <objc/runtime.h>

@implementation TSCStormObject

static TSCStormObject *sharedController = nil;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
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

- (instancetype)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject
{
    if (self = [super init]) {
        
        [self setStormParentObject:parentObject];
    }
    
    return self;
}

- (NSArray *)stormAttributes
{
    return [NSArray array]; // Silences compiler warning
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
    
    // Select a class
    Class class = [TSCStormObject classFromClassName:className parentObject:parentObject];
    
    if (!class) {
        NSLog(@"missing storm object class : %@",className);
    }
    
    // Create it
    id  <TSCStormObjectDataSource> object = nil;
    
    if ([class instancesRespondToSelector:@selector(initWithDictionary:parentObject:)]) {
        object = [[class alloc] initWithDictionary:dictionary parentObject:parentObject];
    } else {
        object = [[class alloc] initWithDictionary:dictionary];
    }
    
    if ([object respondsToSelector:@selector(setStormParentObject:)]) {
        [object setStormParentObject:parentObject];
    }
    
    return object;
}

#pragma mark - Class selection

+ (Class)classFromClassName:(NSString *)className parentObject:(id)parentObject
{
    Class originalClass = NSClassFromString(className);
    Class globalClass = [TSCStormObject globalClassOverideWithClassName:className];
    
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

#pragma mark - Storm object data source

- (id)stormParentObject
{
    return self.parentObject;
}

- (void)setStormParentObject:(id)parentObject
{
    self.parentObject = parentObject;
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
    return [self classFromClassName:className parentObject:nil];
}

- (void)overideClass:(Class)originalClass with:(Class)newClass
{
    if (newClass) {
        [self.overrides setObject:newClass forKey:NSStringFromClass(originalClass)];
    } else {
        [self.overrides removeObjectForKey:NSStringFromClass(originalClass)];
    }
}

+ (void)overideClass:(Class)originalClass with:(Class)newClass
{
    if (newClass) {
        [[[TSCStormObject sharedController] overrides] setObject:newClass forKey:NSStringFromClass(originalClass)];
    } else {
        [[[TSCStormObject sharedController] overrides] removeObjectForKey:NSStringFromClass(originalClass)];
    }
}

@end
