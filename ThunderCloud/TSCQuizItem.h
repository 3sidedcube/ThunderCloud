//
//  TSCQuizQuestion.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 11/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@class TSCZone;

@import ThunderTable;
@import Foundation;

/**
 An object representation of a quiz question.
 
 This is not specific to the type of quiz question, and conforms to the `TSCTableRowDataSource` so can easily be displayed in a table
 
 When shown in a table the row will show whether the question was answered correctly or not in the `textLabel` and will show either a congratulatory string or a suggestion in the `detailTextLabel` dependent on whether the question was answered correctly or not
 */
@interface TSCQuizItem : NSObject <TSCTableRowDataSource>

/**
 Initializes a new quiz item from a CMS representation of a quiz item
 @param dictionary The dictionary used to initialize and populate the quiz item
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 Toggles whether a certain index has been selected by the user or not
 @param index The index of the item to toggle whether the user has selected
 */
- (void)toggleSelectedIndex:(NSIndexPath *)index;

/**
 @abstract The main question text, as in the question being asked to the user
 */
@property (nonatomic, copy) NSString *questionText;

/**
 @abstract A hint as to how the user can or should answer the question
 */
@property (nonatomic, copy) NSString *hintText;

/**
 @abstract A piece of text to display to the user when they answer the question
 */
@property (nonatomic, copy) NSString *completionText;

/**
 @abstract A piece of text to display to the user when you wish to alert them that they answered the question incorrectly
 */
@property (nonatomic, copy) NSString *failureText;

/**
 @abstract A piece of text to display to the user when you wish to alert them that they answered the question correctly
 */
@property (nonatomic, copy) NSString *winText;

/**
 @abstract An array of options which the user can select from to answer a question
 */
@property (nonatomic, strong) NSMutableArray *options;

/**
 @abstract An arbitrary limit on a quiz question
 */
@property (nonatomic, assign) NSInteger limit;

/**
 @abstract An array of indices of answers currently selected by the user
 */
@property (nonatomic, strong) NSMutableArray *selectedIndexes;

/**
 @abstract An array of the indices for the correct answers to the question
 */
@property (nonatomic, strong) NSMutableArray *correctIndexes;

/**
 @abstract Whether or not the question has been answered correctly
 */
@property (nonatomic) BOOL isCorrect;

/**
 @abstract The index of the question in the array of questions on a `TSCQuizPage`
 */
@property (nonatomic) NSInteger questionNumber;

/**
 @abstract The class of the quiz, be it a `TSCTextQuizItem`, `TSCImageQuizItem` e.t.c
 */
@property (nonatomic, copy) NSString *quizClass;

///---------------------------------------------------------------------------------------
/// @name Area Selection Question
///---------------------------------------------------------------------------------------

/**
 @abstract The zone on an image which represents an area in which the user can select and the question will be marked as correct
 */
@property (nonatomic, strong) TSCZone *correctZone;

/**
 @abstract A dictionary representation of the image which a user is selecting an area on
 */
@property (nonatomic, strong) NSDictionary *image;

///---------------------------------------------------------------------------------------
/// @name Slider Question
///---------------------------------------------------------------------------------------

/**
 @abstract The maximum value a user can select for their answer
 */
@property (nonatomic) NSInteger sliderMaxValue;

/**
 @abstract The minimum value a user can select for their answer
 */
@property (nonatomic) NSInteger sliderStartValue;

/**
 @abstract The initial value of the slider to be displayed to the user
 */
@property (nonatomic) NSInteger sliderInitialValue;

/**
 @abstract The units for the question
 */
@property (nonatomic, copy) NSString *sliderUnit;

/**
 @abstract The correct answer for the slider question
 */
@property (nonatomic) NSInteger sliderCorrectAnswer;

///---------------------------------------------------------------------------------------
/// @name Image Selection Question
///---------------------------------------------------------------------------------------

/**
 @abstract The array of possible images for the user to choose from
 */
@property (nonatomic, strong) NSMutableArray *images;

///---------------------------------------------------------------------------------------
/// @name Category Selection Question
///---------------------------------------------------------------------------------------

/**
 @abstract The array of text answers to display to a user for a multiple selection question
 */
@property (nonatomic, strong) NSMutableArray *categories;

@end
