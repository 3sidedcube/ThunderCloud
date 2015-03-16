//
//  TSCImageSelectionQuestion.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 14/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCCollectionViewController.h"

@class TSCQuizItem;

@interface TSCImageQuizItem : TSCCollectionViewController

@property (nonatomic, strong) TSCQuizItem *question;

- (instancetype)initWithQuestion:(TSCQuizItem *)question;

@end
