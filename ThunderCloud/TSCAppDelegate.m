//
//  TSCAppDelegate.m
//  ThunderCloud
//
//  Created by Simon Mitchell on 28/09/2015.
//  Copyright © 2015 threesidedcube. All rights reserved.
//

#import "TSCAppDelegate.h"
#import "TSCStormNotificationHelper.h"
#import "TSCAppViewController.h"
#import "TSCDeveloperController.h"
#import "TSCListPage.h"
#import "TSCQuizPage.h"
@import ThunderTable;
@import CoreSpotlight;

@implementation TSCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.window.rootViewController = [TSCAppViewController new];
    [self.window makeKeyAndVisible];
    
    [[TSCDeveloperController sharedController] installDeveloperModeToWindow:self.window currentTheme:[TSCTheme new]];
    
    //Handling push notifications
    NSDictionary *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if (remoteNotification) {
        [self handlePushNotification:remoteNotification];
    }
    
    return true;
}

#pragma mark - Push Notifications

// Registering for notifications
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [TSCStormNotificationHelper registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [TSCStormNotificationHelper registerPushToken:deviceToken];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[TSCDeveloperController sharedController] appResumedFromBackground];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler
{
    
    if (userActivity.userInfo[CSSearchableItemActivityIdentifier]) {
        
        if ([userActivity.userInfo[CSSearchableItemActivityIdentifier] containsString:@".json"]) {
            
            TSCStormViewController *stormViewController = [[TSCStormViewController alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"caches://pages/%@", userActivity.userInfo[CSSearchableItemActivityIdentifier]]]];
            
            if ([stormViewController isKindOfClass:[TSCListPage class]]) {
                
                stormViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:stormViewController action:@selector(dismissAnimated)];
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:stormViewController];
                [self.window.rootViewController presentViewController:navController animated:YES completion:nil];
                
                return true;
            } else if ([stormViewController isKindOfClass:[TSCQuizPage class]]) {
                
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:stormViewController];
                [self.window.rootViewController presentViewController:navController animated:YES completion:nil];
            }
        }
    }
    
    return false;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self handlePushNotification:userInfo];
}

#pragma mark - Helper Methods

- (void)handlePushNotification:(NSDictionary *)notificationDictionary
{    
    if (self.window.rootViewController.presentedViewController) {
        
        [self performSelector:@selector(handlePushNotification:) withObject:notificationDictionary afterDelay:1];
        
    } else {
        
        //Handle storm pages
        if (notificationDictionary[@"payload"][@"url"]) {
            
            TSCStormViewController *viewController = [[TSCStormViewController alloc] initWithURL:[NSURL URLWithString:notificationDictionary[@"payload"][@"url"]]];
            if (viewController) {
                
                viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:viewController action:@selector(dismissAnimated)];
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
                [self.window.rootViewController presentViewController:navController animated:YES completion:nil];
            }
            
        }
    }
}

@end
