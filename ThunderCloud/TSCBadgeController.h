//
//  TSCQuizController.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 20/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@class TSCBadge;

#import <Foundation/Foundation.h>

#define BADGES_CLEARED_NOTIFICATION @"BadgesClearedNotification"

@interface TSCBadgeController : NSObject

@property (nonatomic, strong) NSMutableArray *badges;

+ (TSCBadgeController *)sharedController;
- (TSCBadge *)badgeForId:(NSString *)badgeId;
- (BOOL)hasEarntBadgeWithId:(NSString *)badgeId;
- (void)markBadgeAsEarnt:(NSString *)badgeId;
- (NSArray *)earnedBadges;
- (float)progressForGridItems:(NSArray *)gridItems;
- (void)clearEarnedBadges;
- (void)reloadBadgeData;

@end
