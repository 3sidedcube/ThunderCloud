//
//  TSCQuizProgressListItemView.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 27/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCListItem.h"

/**
 A table row which displays a users progress through a set of quizzes and upon selection enters the next incomplete quiz in the set
 */
@interface TSCQuizProgressListItemView : TSCListItem

/**
 @abstract An array of quizzes available to the user
 */
@property (nonatomic, strong) NSMutableArray *availableQuizzes;

/**
 @abstract The url reference to the next quiz which is incomplete for the user
 */
@property (nonatomic, strong) NSURL *nextQuizURL;

@end
