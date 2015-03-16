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

@interface TSCQuizItem : NSObject <TSCTableRowDataSource>

@property (nonatomic, copy) NSString *questionText;
@property (nonatomic, copy) NSString *hintText;
@property (nonatomic, copy) NSString *completionText;
@property (nonatomic, copy) NSString *failureText;
@property (nonatomic, copy) NSString *winText;
@property (nonatomic, strong) NSMutableArray *options;
@property (nonatomic, assign) NSInteger limit;
@property (nonatomic, strong) NSMutableArray *selectedIndexes;
@property (nonatomic, strong) NSMutableArray *correctIndexes;
@property (nonatomic) BOOL isCorrect;
@property (nonatomic) NSInteger questionNumber;

//Area Selection
@property (nonatomic, strong) TSCZone *correctZone;
@property (nonatomic, strong) NSDictionary *image;

//Slider question
@property (nonatomic) NSInteger sliderMaxValue;
@property (nonatomic) NSInteger sliderStartValue;
@property (nonatomic) NSInteger sliderInitialValue;
@property (nonatomic, copy) NSString *sliderUnit;
@property (nonatomic) NSInteger sliderCorrectAnswer;

//Image Selection QUestion
@property (nonatomic, strong) NSMutableArray *images;

//Category Selection Question
@property (nonatomic, strong) NSMutableArray *categories;

@property (nonatomic, copy) NSString *quizClass;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (void)toggleSelectedIndex:(NSIndexPath *)index;

@end
