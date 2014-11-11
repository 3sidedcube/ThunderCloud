//
//  TSCStormObject.h
//  ThunderStorm
//
//  Created by Phillip Caudell on 23/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSCStormObjectDataSource.h"

/**
 A subclass of `NSObject` which is the base class of all storm objects. This class is used primarily for overriding standard storm behaviour.
 */
@interface TSCStormObject : NSObject <TSCStormObjectDataSource>

///---------------------------------------------------------------------------------------
/// @name Initialization
///---------------------------------------------------------------------------------------

/**
 @abstract Returns the shared instance of TSCStormObject.
 @discussion This is the instance of `TSCStormObject` that overriding class methods should be called on.
 */
+ (TSCStormObject *)sharedController;

/**
 @abstract Initializes a `TSCStormObject` with a dictionary returned from the Storm CMS.
 @discussion This should be overriden by all subclasses of `TSCStormObject`.
 @param dictionary The dictionary to initialize the object from.
 */
- (id)initWithDictionary:(NSDictionary *)dictionary;

/**
 @abstract Initializes a `TSCStormObject` with a dictionary returned from the Storm CMS.
 @discussion This should be overriden by all subclasses of `TSCStormObject`.
 @param dictionary The dictionary to initialize the object from.
 */
+ (id)objectWithDictionary:(NSDictionary *)dictionary DEPRECATED_ATTRIBUTE;

/**
 @abstract Initializes a `TSCStormObject` with a dictionary returned from the Storm CMS and a parent object.
 @discussion This should be overriden by all subclasses of `TSCStormObject`.
 @param dictionary The dictionary to initialize the object from.
 @param dictionary The parent object to the object being initialized.
 */
- (id)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject;

/**
 @abstract Initializes a `TSCStormObject` with a dictionary returned from the Storm CMS and a parent object.
 @discussion This should be overriden by all subclasses of `TSCStormObject`.
 @param dictionary The dictionary to initialize the object from.
 @param dictionary The parent object to the object being initialized.
 */
+ (id)objectWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject;

///---------------------------------------------------------------------------------------
/// @name Overriding
///---------------------------------------------------------------------------------------

/**
 A dictionary of all the overrides of storm classes.
 */
@property (nonatomic, strong) NSMutableDictionary *overrides;

/**
 The parent object of this current `TSCStormObject`
 */
@property (nonatomic, strong) id parentObject;

/**
 @abstract This method is used to override the class instantiated for any Storm base class.
 @discussion This method allows customising storm standard behaviours. Overriding a class here means that whenever Storm instantiates a class of this type it will use your replacement class. The overriding class should almost always subclass from the overidden class to ensure behaviour of your app isn't effected.
 @param originClass The class to override.
 @param newClass The class to instantiate in replacement of `originalClass`
 */
+ (void)overideClass:(Class)originalClass with:(Class)newClass;

/**
 @abstract This method is used to override the class instantiated for any Storm base class.
 @discussion This method allows customising storm standard behaviours. Overriding a class here means that whenever Storm instantiates a class of this type it will use your replacement class. The overriding class should almost always subclass from the overidden class to ensure behaviour of your app isn't effected.
 @param originClass The class to override.
 @param newClass The class to instantiate in replacement of `originalClass`.
 @deprecated Use +overrideClass:(Class)originalClass with:(Class)newClass instead.
 @warning This method is deprecated, please use `+overrideClass:with:` instead.
 */
- (void)overideClass:(Class)originalClass with:(Class)newClass DEPRECATED_ATTRIBUTE;

/**
 @abstract Returns the class (Be it overriden or not) for a given class key.
 @param key The key for the required class.
 */
+ (Class)classForClassKey:(NSString *)key;

@end