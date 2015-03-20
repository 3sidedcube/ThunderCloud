//
//  TSCQuizPage.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 11/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@import UIKit;

@class TSCBadge;

/**
 A view controller which displays and handles the navigation through a quiz
 
 It's a model and a view controller at the same time! Wohooo
 @discussion This will be re-written soon don't rely on it staying as-is
 */
@interface TSCQuizPage : UIViewController

/**
 Initializes a new instance from a CMS representation of a quiz
 @param dictionary The dictionary to be used to initialize and populate the class
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 Resets the first page of the quiz
 @discussion This should usually be called before displaying a quiz to avoid any previous answers having been trapped in memory and this staying selected
 */
- (void)resetInitialPage;

/**
 @abstract The array of questions for the quiz being displayed
 */
@property (nonatomic, strong) NSMutableArray *questions;

/**
 @abstract The index of the currently displayed quiz question
 */
@property (nonatomic) NSInteger currentIndex;

/**
 @abstract The view controller for the question that is currently displayed to the user
 */
@property (nonatomic, strong) UIViewController *currentViewController;

/**
 @abstract The text to be displayed to the user when they complete the quiz correctly
 */
@property (nonatomic, copy) NSString *winMessage;

/**
 @abstract The text to be displayed to the user when they complete the quiz incorrectly
 */
@property (nonatomic, copy) NSString *loseMessage;

/**
 @abstract The text to be displayed when a user shares the quiz
 */
@property (nonatomic, copy) NSString *shareMessage;

/**
 @abstract The unique identifier for the quiz
 */
@property (nonatomic, copy) NSString *quizId;

/**
 @abstract The badge earned by completing this quiz
 */
@property (nonatomic, strong) TSCBadge *quizBadge;

/**
 @abstract The title of the quiz
 */
@property (nonatomic, copy) NSString *quizTitle;

/**
 @abstract The initial page/question of the quiz
 */
@property (nonatomic, strong) UIViewController *initialQuizQuestion;

/**
 @abstract An array of `TSCLink`s to be shown to the user if they fail to answer a quiz correctly
 */
@property (nonatomic, strong) NSMutableArray *loseRelatedLinks;

/**
 @abstract An array of `TSCLink`s to be shown to the user if they fail to answer a quiz correctly
 */
@property (nonatomic, strong) NSMutableArray *winRelatedLinks;

@end