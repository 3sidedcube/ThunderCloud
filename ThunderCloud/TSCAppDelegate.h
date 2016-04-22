//
//  TSCAppDelegate.h
//  ThunderCloud
//
//  Created by Simon Mitchell on 28/09/2015.
//  Copyright © 2015 threesidedcube. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A root app delegate which sets up your window and push notifications e.t.c.
 */
@interface TSCAppDelegate : UIResponder <UIApplicationDelegate>

/**
 @abstract The main window of the app
 */
@property (strong, nonatomic) UIWindow *window;

/** 
 A method which is called when the user recieves a push notification
 @param notificationDictionary The payload of the push notification
 @param fromLaunch whether the push was recieved when the app opened, or when it was already the foreground app
 @return returns a boolean as to whether the push notification was handled entirely, or whether nothing was done with it
 */
- (BOOL)handlePushNotification:(NSDictionary *)notificationDictionary fromLaunch:(BOOL)fromLaunch;

/**
 Sets up the user agent for all request controllers managed by Thunder Request
 */
- (void)setupSharedUserAgent;

@end
