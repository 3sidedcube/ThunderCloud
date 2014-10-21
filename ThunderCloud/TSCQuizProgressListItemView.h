//
//  TSCQuizProgressListItemView.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 27/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCStandardListItem.h"

@interface TSCQuizProgressListItemView : TSCStandardListItem

@property (nonatomic, strong) NSMutableArray *availableQuizzes;
@property (nonatomic, strong) NSURL *nextQuizURL;

@end
