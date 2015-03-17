//
//  TSCTextSelectionQuestionViewController.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 11/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@import ThunderTable;

@class TSCQuizItem;

/**
 A table view which presents the user with a question and hint with a list of textual options to select from below
 
 This can be multiple or single selection
 */
@interface TSCTextQuizItem : TSCTableViewController

/**
 Initializes a new object with a given `TSCQuizItem`
 @param question The question to be displayed to the user
 */
- (instancetype)initWithQuestion:(TSCQuizItem *)question;

/**
 @abstract The quiz item being displayed in the `TSCTableViewController`
 */
@property (nonatomic, strong) TSCQuizItem *question;

/**
 @abstract An array of `TSCQuizCheckableView` objects which are the views which allow a user to select an answer(s) to the question
 */
@property (nonatomic, strong) NSMutableArray *optionViews;

@end
