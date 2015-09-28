//
//  TSCAppDelegate.h
//  ThunderCloud
//
//  Created by Simon Mitchell on 28/09/2015.
//  Copyright © 2015 threesidedcube. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)handlePushNotification:(NSDictionary *)notificationDictionary;

@end
