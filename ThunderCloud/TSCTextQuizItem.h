//
//  TSCTextSelectionQuestionViewController.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 11/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@import ThunderTable;

@class TSCQuizItem;

@interface TSCTextQuizItem : TSCTableViewController

@property (nonatomic, strong) TSCQuizItem *question;
@property (nonatomic, strong) NSMutableArray *optionViews;

- (instancetype)initWithQuestion:(TSCQuizItem *)question;

@end
