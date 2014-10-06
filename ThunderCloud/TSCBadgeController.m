//
//  TSCQuizController.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 20/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCBadgeController.h"
#import "TSCBadge.h"
#define STORM_QUIZ_KEY @"TSCCompletedQuizes"
#import "TSCGridItem.h"
#import "TSCBadgeController.h"
#import "TSCContentController.h"

@implementation TSCBadgeController

static TSCBadgeController *sharedController = nil;

+ (TSCBadgeController *)sharedController
{
    @synchronized(self) {
        
        if (sharedController == nil) {
            sharedController = [[self alloc] init];
        }
    }
    
    return sharedController;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        
        //Ready for badges
        self.badges = [NSMutableArray array];
        
        //Load up badges JSON
        NSString *badgesFile = [[TSCContentController sharedController] pathForResource:@"badges" ofType:@"json" inDirectory:@"data"];
        
        if (badgesFile) {
            
            NSData *data = [NSData dataWithContentsOfFile:badgesFile];
            NSArray *badgeJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if (badgeJSON) {
                
                for (NSDictionary *badgeDictionary in badgeJSON) {
                    TSCBadge *badge = [[TSCBadge alloc] initWithDictionary:badgeDictionary];
                    [self.badges addObject:badge];
                }
            }
        }
    }
    
    return self;
}

#pragma mark Badge lookup

- (TSCBadge *)badgeForId:(NSNumber *)badgeId
{
    if (badgeId) {
        for (TSCBadge *badge in self.badges) {
            if ([badge.badgeId isEqualToNumber:badgeId]) {
                return badge;
            }
        }
    }
    
    return [[TSCBadge alloc] init];
}

#pragma mark Won badge tracking

- (BOOL)hasEarntBadgeWithId:(NSNumber *)badgeId
{
    NSMutableArray *earnedBadges;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:STORM_QUIZ_KEY]) {
        earnedBadges = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:STORM_QUIZ_KEY]];
    } else {
        earnedBadges = [NSMutableArray array];
    }

    for (NSNumber *quizId in earnedBadges) {
        if ([quizId isEqualToNumber:badgeId]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)markBadgeAsEarnt:(NSNumber *)badgeId
{
    if (badgeId && ![self hasEarntBadgeWithId:badgeId]) {
        
        NSMutableArray *currentEarnedBadges;
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:STORM_QUIZ_KEY]) {
            currentEarnedBadges = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:STORM_QUIZ_KEY]];
        } else {
            currentEarnedBadges = [NSMutableArray array];
        }
        
        [currentEarnedBadges addObject:badgeId];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:currentEarnedBadges] forKey:STORM_QUIZ_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCStatEventNotification" object:self userInfo:@{@"type":@"event", @"category":@"Badges", @"action":[NSString stringWithFormat:@"%lu of %lu", (unsigned long)[self earnedBadges].count, (unsigned long)self.badges.count]}];

}

- (NSArray *)earnedBadges
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:STORM_QUIZ_KEY]) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:STORM_QUIZ_KEY]];
    } else {
        return [NSMutableArray array];
    }
}

- (float)progressForGridItems:(NSArray *)gridItems
{
    float numberOfbadgesAvailable = gridItems.count;
    int numberOfBadgesEarned = 0;
    
    for (TSCGridItem *gridItem in gridItems) {
        for (NSNumber *quizId in [self earnedBadges]) {
            if ([gridItem.badgeId integerValue] == [quizId integerValue]) {
                numberOfBadgesEarned++;
            }
        }
    }
    
    return numberOfBadgesEarned / numberOfbadgesAvailable;
}

#pragma mark - Removing badges methods

-(void)clearEarnedBadges {
    NSMutableArray *earnedBadges = [NSMutableArray new];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:earnedBadges] forKey:STORM_QUIZ_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BADGES_CLEARED_NOTIFICATION object:nil];
}

@end
