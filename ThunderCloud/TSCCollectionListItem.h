//
//  TSCCollectionListItemView.h
//  ThunderCloud
//
//  Created by Sam Houghton on 09/04/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSCSpotlightImageListItem.h"

typedef NS_ENUM(NSInteger, TSCCollectionListItemViewType) {
    TSCCollectionListItemViewQuizBadgeShowcase = 1,
    TSCCollectionListItemViewAppShowcase = 2
};

@interface TSCCollectionListItem : TSCStandardListItem

@property (nonatomic) TSCCollectionListItemViewType type;
@property (nonatomic, strong) NSMutableArray *badges;
@property (nonatomic, strong) NSMutableArray *objects;

- (void)loadQuizzesQuizCells:(NSArray *)quizCells;

@end
