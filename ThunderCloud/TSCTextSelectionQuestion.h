//
//  TSCTextSelectionQuestionViewController.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 11/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@import ThunderTable;

@class TSCQuizQuestion;

@interface TSCTextSelectionQuestion : TSCTableViewController

@property (nonatomic, strong) TSCQuizQuestion *question;

- (id)initWithQuestion:(TSCQuizQuestion *)question;

@end
