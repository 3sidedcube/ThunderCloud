//
//  TSCDeveloperController.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 14/01/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

@class TSCTheme;
@class TSCRequestController;

@import Foundation;
@import UIKit;

/**
 The developer controller is responsible for handling mode switching of storm apps.
 
 Storm apps have two modes;
 
 - Dev: Displays content from the CMS that has been published to test
 - Live: Displays content from the CMS published to live
 
 In Developer mode the app will switch to a green colour scheme to remind the user that they are in dev mode
 */
@interface TSCDeveloperController : NSObject

/**
 The base URL of the CMS that will be used to retrieve bundles
 */
@property (nonatomic, strong) NSURL *baseURL;

/**
 The request controller responsible for getting information about available bundles from the CMS
 */
@property (nonatomic, strong) TSCRequestController *requestController;

/**
 The shared instance of the developer controller responsible for monitoring switching to dev/live mode
 */
+ (TSCDeveloperController *)sharedController;

/**
 Whether or not the app is currently in dev mode
 @return YES if the app is in dev mode
 */
+ (BOOL)isDevMode;

/**
 Begins the process of switching the app to dev mode
 */
- (void)switchToLiveMode;

/**
 Logs the user into dev mode
 */
- (void)loginToDevMode;

/**
 Configures dev mode for the given window.
 @param window The window that will be refreshed when dev mode is enabled
 @param currentTheme The current `TSCTheme` of the app. This will be restored when switching back to live mode
 */
- (void)installDeveloperModeToWindow:(UIWindow *)window currentTheme:(TSCTheme *)currentTheme;

/**
 By implementing this method you are supplying a custom target and selector that will be called when the app is ready to switch modes.
 @param target The target to call when the app is ready to switch modes
 @param selector The selector to call when the app is ready to switch modes
 @note If you are not using `TSCAppViewController` as your windows root view controller you will need to implement this method
 */
- (void)overrideRefreshTarget:(id)target selector:(SEL)selector;

/**
 Provides functionality for re-running theme customisation after restoring from Dev mode. Use this method to register a method that handles your default app theming config.
 @param target The target to call after switching to live mode
 @param selector The selector to call after switching to live mode
 */
- (void)registerThemeCustomisationTarget:(id)target selector:(SEL)selector;

/**
 @param The current theme which the user will be switched back to when they exit developer mode
 */
@property (nonatomic, strong) TSCTheme *currentTheme;

@end


