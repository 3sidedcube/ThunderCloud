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
#import "TSCStormConstants.h"
#import <ThunderCloud/ThunderCloud-Swift.h>
@import ThunderTable;
@import ThunderBasics;
@import CoreSpotlight;
@import ThunderRequest;

@interface TSCAppDelegate ()

@property (nonatomic, strong) NSTimer *pushTimer;

@end

@implementation TSCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.window.rootViewController = [TSCAppViewController new];
    [self.window makeKeyAndVisible];
    
    [self setupSharedUserAgent];
    
    [[TSCDeveloperController sharedController] installDeveloperModeToWindow:self.window currentTheme:[TSCTheme new]];
    
    //Register errors
    [TSCErrorRecoveryAttempter registerOverrideDescription:[NSString stringWithLocalisationKey:@"_STREAMINGPAGE_FAILED_TITLE" fallbackString:@"Failed to load page"] recoverySuggestion:[NSString stringWithLocalisationKey:@"_STREAMINGPAGE_FAILED_RECOVERYSUGGESTION" fallbackString:@"We were unable to find the page for this notification"] forDomain:@"ThunderCloud.streamingError" code:1];
    
    //Handling push notifications
    NSDictionary *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if (remoteNotification) {
        [self handlePushNotification:remoteNotification fromLaunch:true];
    }
    
    return true;
}

- (void)setupSharedUserAgent
{
    [TSCRequestController setUserAgent:[TSCStormConstants userAgent]];
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
    [self handlePushNotification:userInfo fromLaunch:(application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground)];
}

#pragma mark - Helper Methods

- (BOOL)handlePushNotification:(NSDictionary *)notificationDictionary fromLaunch:(BOOL)fromLaunch
{    
    if (notificationDictionary[@"payload"][@"url"]) {
    
        if (self.window.rootViewController.presentedViewController) {
    
                double delayInSeconds = 1.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    
                    [self handlePushNotification:notificationDictionary fromLaunch:fromLaunch];
                    
                });
    
        } else {
        
            if (notificationDictionary && [notificationDictionary isKindOfClass:[NSDictionary class]] && notificationDictionary[@"payload"] && [notificationDictionary[@"payload"] isKindOfClass:[NSDictionary class]] && notificationDictionary[@"payload"][@"url"] && [notificationDictionary[@"payload"][@"url"] isKindOfClass:[NSString class]]) {
                
                if (![[NSBundle mainBundle] infoDictionary][@"TSCStreamingBaseURL"]) {

                    // Local
                    TSCStormViewController *viewController = [[TSCStormViewController alloc] initWithURL:[NSURL URLWithString:notificationDictionary[@"payload"][@"url"]]];
                    
                    if (viewController) {
                        
                        viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:viewController action:@selector(dismissAnimated)];
                        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
                        [self.window.rootViewController presentViewController:navController animated:YES completion:nil];
                    }
                } else {
                    
                    // Remote

                    [MDCHUDActivityView startInView:self.window];
                    TSCStreamingPagesController *pages = [TSCStreamingPagesController new];
                    [pages fetchStreamingPageWithCacheURLString:notificationDictionary[@"payload"][@"url"] completion:^(TSCStormViewController *stormView, NSError *error) {
                        
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [MDCHUDActivityView finishInView:self.window];
                        }];

                        if (error) {
                            [UIAlertController presentError:error inViewController:self.window.rootViewController];
                        }
                        
                        if (stormView) {
                            
                            stormView.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissStreamedPage)];
                            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:stormView];
                            [self.window.rootViewController presentViewController:navController animated:YES completion:nil];
                        }
                    }];
                }
            }
        }
        
        return true;
    }
    
    return false;
}

- (void)dismissStreamedPage
{
    [self.window.rootViewController dismissViewControllerAnimated:true completion:nil];
    [TSCStreamingPagesController cleanUp];
}

@end
