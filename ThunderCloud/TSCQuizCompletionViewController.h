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

/**
 A table which will be shown to the user upon them answering all of the questions in a quiz
 
 This view will calculate whether the user has answered the quiz correctly and display either hints on which questions a user answered incorrectly or display a congratulatory view
 
 This class will also send out `NSNotificationCenter` notifications to alert other views that the user has completed a quiz
 */
@interface TSCQuizCompletionViewController : TSCTableViewController


/**
 Initializes a new completion screen with the `TSCQuizPage` which the user has just completed and the array of questions they have just answered
 @param quizPage The quiz page the user has just come from
 @param question The array of quiz questions the user has just answered

 */
- (instancetype)initWithQuizPage:(TSCQuizPage *)quizPage questions:(NSArray *)questions;

/**
 Returns whether the quiz was answered correctly or not
 */
- (BOOL)quizIsCorrect;

/**
 This will be called when a user selects to retry the quiz
 @param selection The table view selection object sent to the method when the user selects to retry
 */
- (void)handleRetry:(TSCTableSelection *)selection;

/**
 The method which is called when the user clicks to share the badge related to the completed quiz
 @param shareButton The button which the user hit to share the badge
 */
- (void)shareBadge:(UIBarButtonItem *)shareButton;

/**
 The method which is called when the user clicks to dismiss the quiz completion view
 @param barButtonItem The button which the user hit to dismiss the view
 */
- (void)finishQuiz:(UIBarButtonItem *)barButtonItem;

/**
 Returns an array of `UIBarButtonItem`s to be displayed to the user in the left of the navigation bar.
 @discussion By default this returns a share button
 */
- (NSArray *)additionalLeftBarButtonItems;

/**
 Returns the button to be displayed to the user on the right of the navigation bar
 @discussion By default this returns a button which the user can click to finish the quiz
 */
- (UIBarButtonItem *)rightBarButtonItem;

/**
 Returns a table row for a link related to the completed quiz
 @discussion May, for example, contain a link to a token or sale if a user has correctly answered a quiz
 @param The link which the row should take the user to upon selection
 @param Whether the user completed the quiz correctly
 @discussion The default implementation for this method simply returns a table row with the title of the link provided to it
 */
+ (NSObject *)rowForRelatedLink:(TSCLink *)link correctQuiz:(BOOL)correctQuiz;

/**
 @abstract An array of the questions which were asked of the user in the quiz
 */
@property (nonatomic, strong) NSArray *questions;

/**
 @abstract The quiz page which the user has come from
 */
@property (nonatomic, strong) TSCQuizPage *quizPage;

@end
