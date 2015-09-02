//
//  TSCStormNotificationHelper.h
//  ThunderCloud
//
//  Created by Matt Cheetham on 05/11/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

@import ThunderBasics;

/**
 `TSCStormNotificationHelper` is a subsclas of `TSCNotificationHelper` that aids the registering of push notifications
 */
@interface TSCStormNotificationHelper : TSCNotificationHelper

/**
 @abstract Registers the newly delivered push token to the storm servers so that the system can send notifications to the device
 @discussion Call this method in the `application:didRegisterForRemoteNotificationsWithDeviceToken:` method and pass the pushToken
 @param pushTokenData The token supplied by the `application:didRegisterForRemoteNotificationsWithDeviceToken:` method
 */
+ (void)registerPushToken:(NSData *)pushTokenData;

/**
 @abstract Registers the newly delivered push token to the storm servers so that the system can send notifications to the device
 @discussion Call this method in the `application:didRegisterForRemoteNotificationsWithDeviceToken:` method and pass the pushToken
 @param pushTokenData The token supplied by the `application:didRegisterForRemoteNotificationsWithDeviceToken:` method
 @param geoTargeted Whether the user's location should be sent with the push token for geo-targeted push notifications
 */
+ (void)registerPushToken:(NSData *)pushTokenData geoTargeted:(BOOL)geoTargeted;

/**
 @abstract Returns a tidied up string of the push token data.
 @discussion This can be used to create a push token which can be sent to an endpoint for registering push tokens for an api or service.
 @param pushTokenData The token supplied by the `application:didRegisterForRemoteNotificationsWithDeviceToken:` method
 */
+ (NSString *)stringForPushTokenData:(NSData *)pushTokenData;


@end
