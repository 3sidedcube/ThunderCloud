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
 @param pushToken The token supplied by the `application:didRegisterForRemoteNotificationsWithDeviceToken:` method
 */
+ (void)registerPushToken:(NSData *)pushTokenData;


@end
