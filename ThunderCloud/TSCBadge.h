//
//  TSCBadge.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 20/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 `TSCBadge` is a model representation of storm badge object
 
 */
@interface TSCBadge : NSObject

/**
 @abstract A string of text that is displayed when the badge is unlocked
 @discussion This gets diplsayed when a user has succefully unlocked a badge and views it
 */
@property (nonatomic, copy) NSString *badgeCompletionText;

/**
 @abstract A string of text that informs the user on how to unlock the badge
 @discussion This text normally gets displayed when a user views a badge before it is unlocked
 */
@property (nonatomic, copy) NSString *badgeHowToEarnText;

/**
 @abstract A `NSDictionary` representation of the badges icon
 @discussion This `NSDictionary` can be parsed into a `TSCImage` to return a `UIImage` representation of the icon
 */
@property (nonatomic, strong) NSDictionary *badgeIcon;

/**
 @abstract The text that is used when the user shares the badge
 @discussion This contains a message and a web link the the badge
 */
@property (nonatomic, copy) NSString *badgeShareMessage;

/**
 @abstract The title of the badge
 */
@property (nonatomic, copy) NSString *badgeTitle;

/**
 @abstract A unique id for the badge
 */
@property (nonatomic, copy) NSString *badgeId;

/**
 Initializes the `TSCBadge`
 @param dictionary A `NSDictionary` representation of a badge
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end