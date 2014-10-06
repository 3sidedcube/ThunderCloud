//
//  TSCBadge.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 20/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSCBadge : NSObject

@property (nonatomic, strong) NSString *badgeCompletionText;
@property (nonatomic, strong) NSString *badgeHowToEarnText;
@property (nonatomic, strong) NSDictionary *badgeIcon;
@property (nonatomic, strong) NSString *badgeShareMessage;
@property (nonatomic, strong) NSString *badgeTitle;
@property (nonatomic, strong) NSNumber *badgeId;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end