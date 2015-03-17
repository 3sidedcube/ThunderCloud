//
//  TSCBadgeShareViewController.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 28/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCAchievementDisplayView.h"

@class TSCBadge;

/**
 `TSCBadgeShareViewController` is a `UIViewController` that displays the badge and its completion text once it has been completed. It also has a share button which brings up a `UIActivityViewController`
 */
@interface TSCBadgeShareViewController : UIViewController

/**
 @abstract A `TSCAchievementDisplayView` that displays the badge and its title
 */
@property (nonatomic, strong) TSCAchievementDisplayView *achievementView;

/**
 @abstract A `TSCBadge` that is displayed in the controller
 */
@property (nonatomic, strong) TSCBadge *badge;

/**
 @abstract The share text that is used when the badge is shared
 */
@property (nonatomic, copy) NSString *shareMessage;

/**
 Creates a new instance of `TSCBadgeShareViewController` with a `TSCBadge`
 @param badge A `TSCBadge` that will be displayed in the view controller
 */
- (id)initWithBadge:(TSCBadge *)badge;

@end
