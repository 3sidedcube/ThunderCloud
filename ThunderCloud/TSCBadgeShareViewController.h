//
//  TSCBadgeShareViewController.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 28/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCAchievementDisplayView.h"

@class TSCBadge;

@interface TSCBadgeShareViewController : UIViewController

@property (nonatomic, strong) TSCAchievementDisplayView *achievementView;
@property (nonatomic, strong) TSCBadge *badge;
@property (nonatomic, copy) NSString *shareMessage;

- (id)initWithBadge:(TSCBadge *)badge;

@end
