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

@end


