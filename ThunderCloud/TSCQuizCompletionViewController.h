//
//  TSCQuizCompletionViewController.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 12/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@import ThunderTable;

@class TSCQuizPage;

#import "TSCQuizPage.h"
#import "TSCLink.h"

#define OPEN_NEXT_QUIZ_NOTIFICATION @"OPEN_NEXT_QUIZ_NOTIFICATION"
#define QUIZ_COMPLETED_NOTIFICATION @"QUIZ_COMPLETED_NOTIFICATION"

@protocol TSCQuizCompletionDelegate <NSObject>

@end

@interface TSCQuizCompletionViewController : TSCTableViewController

@property (nonatomic, strong) NSArray *questions;
@property (nonatomic, strong) TSCQuizPage *quizPage;

- (id)initWithQuizPage:(TSCQuizPage *)quizPage questions:(NSArray *)questions;

- (BOOL)quizIsCorrect;
- (void)handleRetry:(TSCTableSelection *)selection;
- (void)shareBadge:(UIBarButtonItem *)shareButton;
- (void)finishQuiz:(UIBarButtonItem *)barButtonItem;

-(NSArray *)additionalLeftBarButtonItems;
-(UIBarButtonItem *)rightBarButtonItem;

+(NSObject *)rowForRelatedLink:(TSCLink *)link correctQuiz:(BOOL)correctQuiz;

@end
