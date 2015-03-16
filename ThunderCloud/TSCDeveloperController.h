//
//  TSCDeveloperController.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 14/01/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

@class TSCDefaultTheme;
@class TSCRequestController;

@import Foundation;
@import UIKit;

@interface TSCDeveloperController : NSObject

@property (nonatomic, strong) NSURL *baseURL;

@property (nonatomic, strong) TSCRequestController *requestController;

+ (TSCDeveloperController *)sharedController;
+ (BOOL)isDevMode;
- (void)switchToLiveMode;
- (void)loginToDevMode;
- (void)appResumedFromBackground;
- (void)installDeveloperModeToWindow:(UIWindow *)window currentTheme:(TSCDefaultTheme *)currentTheme;
- (void)overrideRefreshTarget:(id)target selector:(SEL)selector;

/**
 Provides functionality for re-running theme customisation after restoring from Dev mode. Use this method to register a method that handles your default app theming config.
 @param target The target to call after switching to live mode
 @param selector The selector to call after switching to live mode
 */
- (void)registerThemeCustomisationTarget:(id)target selector:(SEL)selector;

@end


