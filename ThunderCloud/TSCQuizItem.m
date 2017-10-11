//
//  TSCQuizQuestion.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 11/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCQuizItem.h"
#import "TSCQuizResponseTextOption.h"
#import "TSCZone.h"
#import "NSString+LocalisedString.h"
#import <ThunderCloud/ThunderCloud-Swift.h>

@import ThunderBasics;

@implementation TSCQuizItem

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        
        self.questionText = [[TSCStormLanguageController sharedController] stringForDictionary:(dictionary[@"title"])];
        self.hintText = [[TSCStormLanguageController sharedController] stringForDictionary:(dictionary[@"hint"])];
        
        self.completionText = [[TSCStormLanguageController sharedController] stringForDictionary:(dictionary[@"completion"])];
        self.failureText = [[TSCStormLanguageController sharedController] stringForDictionary:(dictionary[@"failure"])];
        self.winText = [[TSCStormLanguageController sharedController] stringForDictionary:(dictionary[@"win"])];
        
        self.quizClass = [NSString stringWithFormat:@"TSC%@", dictionary[@"class"]];
        
        self.options = [NSMutableArray array];
        
        if (dictionary[@"options"]) {
            
            for (NSDictionary *questionOption in dictionary[@"options"]) {
                
                TSCQuizResponseTextOption *responseOption = [[TSCQuizResponseTextOption alloc] initWithDictionary:questionOption];
                [self.options addObject:responseOption];
            }
        }
        
        if (dictionary[@"image"]) {
            
            self.image = dictionary[@"image"];
        }
        
        self.correctIndexes = [NSMutableArray array];
        
        if (dictionary[@"answer"]) {
            
            self.correctIndexes = dictionary[@"answer"];
            
            if ([dictionary[@"class"] isEqualToString:@"AreaSelectionQuestion"] || [dictionary[@"class"] isEqualToString:@"AreaQuizItem"]) {
                
                TSCZone *zone = [[TSCZone alloc] initWithDictionary:dictionary[@"answer"][0]];
                self.correctZone = zone;
                
            } else if ([dictionary[@"class"] isEqualToString:@"SliderQuizItem"] || [dictionary[@"class"] isEqualToString:@"ImageSliderSelectionQuestion"]) {
                
                self.sliderCorrectAnswer = [dictionary[@"answer"] integerValue];
            }
        }
        
        // Slider question
        if (dictionary[@"range"]) {
            self.sliderStartValue = [dictionary[@"range"][@"start"] integerValue];
            self.sliderMaxValue = self.sliderStartValue + [dictionary[@"range"][@"length"] integerValue];
        }
        
        if (dictionary[@"initialPosition"]) {
            self.sliderInitialValue = [dictionary[@"initialPosition"] integerValue];
        }
        
        if (dictionary[@"unit"]) {
            self.sliderUnit = [[TSCStormLanguageController sharedController] stringForDictionary:(dictionary[@"unit"])];
        }
        
        // Image Selection Question
        self.images = [NSMutableArray array];
        
        if (dictionary[@"images"]) {
            
            for (NSDictionary *image in dictionary[@"images"]) {
                
                [self.images addObject:image];
            }
        }
        
        // Category selection questions
        self.categories = [NSMutableArray array];
        
        if (dictionary[@"categories"]) {
            
            for (NSDictionary *categoryDictionary in dictionary[@"categories"]) {
                
                if ([[TSCStormLanguageController sharedController] stringForDictionary:(categoryDictionary)]) {
                    [self.categories addObject:[[TSCStormLanguageController sharedController] stringForDictionary:(categoryDictionary)]];
                }
            }
        }
        
        self.limit = [dictionary[@"limit"] integerValue];
        
        self.selectedIndexes = [NSMutableArray array];
        
        self.isCorrect = NO;
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject
{
    if (self = [super init]) {
        
        self.questionText = [[TSCStormLanguageController sharedController] stringForDictionary:(dictionary[@"title"])];
        self.hintText = [[TSCStormLanguageController sharedController] stringForDictionary:(dictionary[@"hint"])];
        
        self.completionText = [[TSCStormLanguageController sharedController] stringForDictionary:(dictionary[@"completion"])];
        self.failureText = [[TSCStormLanguageController sharedController] stringForDictionary:(dictionary[@"failure"])];
        self.winText = [[TSCStormLanguageController sharedController] stringForDictionary:(dictionary[@"win"])];
        
        self.quizClass = [NSString stringWithFormat:@"TSC%@", dictionary[@"class"]];
        
        self.options = [NSMutableArray array];
        
        if (dictionary[@"options"]) {
            
            for (NSDictionary *questionOption in dictionary[@"options"]) {
                
                TSCQuizResponseTextOption *responseOption = [[TSCQuizResponseTextOption alloc] initWithDictionary:questionOption];
                [self.options addObject:responseOption];
            }
        }
        
        if (dictionary[@"image"]) {
            
            self.image = dictionary[@"image"];
        }
        
        self.correctIndexes = [NSMutableArray array];
        
        if (dictionary[@"answer"]) {
            
            self.correctIndexes = dictionary[@"answer"];
            
            if ([dictionary[@"class"] isEqualToString:@"AreaSelectionQuestion"] || [dictionary[@"class"] isEqualToString:@"AreaQuizItem"]) {
                
                TSCZone *zone = [[TSCZone alloc] initWithDictionary:dictionary[@"answer"][0]];
                self.correctZone = zone;
                
            } else if ([dictionary[@"class"] isEqualToString:@"SliderQuizItem"]  || [dictionary[@"class"] isEqualToString:@"ImageSliderSelectionQuestion"]) {
                
                self.sliderCorrectAnswer = [dictionary[@"answer"] integerValue];
            }
        }
        
        // Slider question
        if (dictionary[@"range"]) {
            self.sliderStartValue = [dictionary[@"range"][@"start"] integerValue];
            self.sliderMaxValue = self.sliderStartValue + [dictionary[@"range"][@"length"] integerValue];
        }
        
        if (dictionary[@"initialPosition"]) {
            self.sliderInitialValue = [dictionary[@"initialPosition"] integerValue];
        }
        
        if (dictionary[@"unit"]) {
            self.sliderUnit = [[TSCStormLanguageController sharedController] stringForDictionary:(dictionary[@"unit"])];
        }
        
        // Image Selection Question
        self.images = [NSMutableArray array];
        
        if (dictionary[@"images"]) {
            
            for (NSDictionary *image in dictionary[@"images"]) {
                
                [self.images addObject:image];
            }
        }
        
        // Category selection questions
        self.categories = [NSMutableArray array];
        
        if (dictionary[@"categories"]) {
            
            for (NSDictionary *categoryDictionary in dictionary[@"categories"]) {
                
                [self.categories addObject:[[TSCStormLanguageController sharedController] stringForDictionary:(categoryDictionary)]];
            }
        }
        
        self.limit = [dictionary[@"limit"] integerValue];
        
        self.selectedIndexes = [NSMutableArray array];
        
        self.isCorrect = NO;
    }
    
    return self;
}

#pragma mark Text Selection Question handling

- (void)toggleSelectedIndex:(NSIndexPath *)index
{
    if ([self.selectedIndexes containsObject:index]) {
        [self.selectedIndexes removeObject:index];
    } else {
        [self.selectedIndexes addObject:index];
    }
    
    self.isCorrect = [self validateResponses];
}

- (BOOL)validateResponses
{
    if (self.selectedIndexes.count != self.correctIndexes.count) {
        return 0;
    }
    
    int correctAnswers = 0;
    
    for (int i = 0; i < self.selectedIndexes.count; i++) {
        
        NSIndexPath *selectedIndex = self.selectedIndexes[i];
        
        for (NSString *answer in self.correctIndexes) {
            if ([answer intValue] == selectedIndex.row) {
                correctAnswers++;
            }
        }
    }
    
    return (correctAnswers == self.correctIndexes.count);
}

#pragma mark Row data source

- (NSString *)rowTitle
{
    return self.isCorrect ? [NSString stringWithLocalisationKey:@"_TEST_CORRECT" fallbackString:@"Correct"] : self.questionText;
}

- (NSString *)rowSubtitle
{
    return self.isCorrect ? self.winText : self.failureText;
}

- (BOOL)canEditRow
{
    return NO;
}

- (UIImage *)rowImage
{
    return nil;
}

- (NSURL *)rowImageURL
{
    return nil;
}

- (id)rowSelectionTarget
{
    return nil;
}

- (SEL)rowSelectionSelector
{
    return nil;
}

- (TSCLink *)rowLink
{
    return nil;
}

- (Class)tableViewCellClass
{
    return [NumberedViewCell class];
}

- (UITableViewCell *)tableViewCell:(UITableViewCell *)cell
{
    NumberedViewCell *numberCell = (NumberedViewCell *)cell;
    numberCell.numberLabel.text = [NSString stringWithFormat:@"%li", (long)self.questionNumber];
    
    return numberCell;
}

@end
