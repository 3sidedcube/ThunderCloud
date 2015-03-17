//
//  TSCQuizBadgeShowcaseView.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 26/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSCSpotlightImageListItem.h"

/**
 A table row which shows a collection of badges related to the quizzes available in the application
 
 Incomplete quizzes (or the badge attached to them) are shown slightly transparent.
 
 Once a badge has been earnt clicking on it will open a share sheet for the user to share the badge
 */
@interface TSCQuizBadgeShowcase : TSCListItem

/**
 @abstract The array of badges to be displayed in the row
 */
@property (nonatomic, strong) NSMutableArray *badges;

@end
