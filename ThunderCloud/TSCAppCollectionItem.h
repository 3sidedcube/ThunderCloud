//
//  TSCAppCollectionItem.h
//  ThunderCloud
//
//  Created by Matt Cheetham on 26/06/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

@class TSCAppIdentity;

@import Foundation;
@import UIKit;

/**
 A model representation of an app to be shown in a `TSCAppScrollerItemViewCell`
 */
@interface TSCAppCollectionItem : NSObject

/**
 Initializes a new instance from a CMS representation of an app
 @param dictionary The dictionary to use to initialize and populate the app
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 @abstract The app icon for the app
 */
@property (nonatomic, strong) UIImage *appIcon;

/**
 @abstract The app identity for the app, contains information on the URL schemes, app name, iTunes id e.t.c
 @see `TSCAppIdentity`
 */
@property (nonatomic, strong) TSCAppIdentity *appIdentity;

/**
 @abstract The name of the app
 */
@property (nonatomic, copy) NSString *appName;

/**
 @abstract The price of the app
 */
@property (nonatomic, copy) NSString *appPrice;

@end
