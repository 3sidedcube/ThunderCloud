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

@property (nonatomic, strong) NSString *questionText;
@property (nonatomic, strong) NSString *hintText;
@property (nonatomic, strong) NSString *completionText;
@property (nonatomic, strong) NSString *failureText;
@property (nonatomic, strong) NSString *winText;
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
@property (nonatomic, strong) NSString *sliderUnit;
@property (nonatomic) NSInteger sliderCorrectAnswer;

//Image Selection QUestion
@property (nonatomic, strong) NSMutableArray *images;

//Category Selection Question
@property (nonatomic, strong) NSMutableArray *categories;

@property (nonatomic, strong) NSString *quizClass;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void)toggleSelectedIndex:(NSIndexPath *)index;

@end
