//
//  TSCBadgeController.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 20/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@class TSCBadge;

#import <Foundation/Foundation.h>

#define BADGES_CLEARED_NOTIFICATION @"BadgesClearedNotification"

/**
 `TSCBadgeController` is a controller for managing badges, when first initialized it loads a `NSMutableArray` of `TSCBadge`s from the content controller
 */
@interface TSCBadgeController : NSObject

/**
 @abstract A `NSArray` of `TSCBadge`s
 @discussion Gets set when the `TSCBadgeController` is initalized
 */
@property (nonatomic, strong) NSMutableArray *badges;

/**
 Returns a shared instance of `TSCBadgeController`
 */
+ (instancetype)sharedController;

/**
 Returns a `TSCBadge` for the given id
 @param badgeId The unique id for the `TSCBadge`
 */
- (TSCBadge *)badgeForId:(NSString *)badgeId;

/**
 Returns a BOOL for whether the user had unlocked the badge or not
 @param badgeId The unique id for the `TSCBadge`
 */
- (BOOL)hasEarntBadgeWithId:(NSString *)badgeId;

/**
 Marks and saves a badge as earnt
 @param badgeId The unique id for the `TSCBadge`
 */
- (void)markBadgeAsEarnt:(NSString *)badgeId;

/**
 Returns a `NSArray` of `TSCBadges` that have been earnt
 */
- (NSArray *)earnedBadges;

/**
 Returns a perecentage of completion for the earnt badges
 @param gridItems A `NSArray` of `TSCGridItem`s that represent a badge
 */
- (float)progressForGridItems:(NSArray *)gridItems;

/**
 Resets all the users earned badges
 */
- (void)clearEarnedBadges;

/**
 Reloads the badge data from the app bundle
 */
- (void)reloadBadgeData;

@end
