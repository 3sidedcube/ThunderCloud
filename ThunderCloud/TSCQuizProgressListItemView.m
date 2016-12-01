//
//  TSCQuizProgressListItemView.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 27/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@import ThunderBasics;

#import "TSCQuizProgressListItemView.h"
#import "TSCQuizPage.h"
#import "TSCBadge.h"
#import "TSCProgressListItemViewCell.h"
#import "TSCQuizCompletionViewController.h"
#import "ThunderCloud/ThunderCloud-Swift.h"
#import "TSCBadgeController.h"
#import "UINavigationController+TSCNavigationController.h"
#import "NSString+LocalisedString.h"
#import "TSCStormLanguageController.h"

@implementation TSCQuizProgressListItemView

- (instancetype)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject
{
    if (self = [super init]) {
        
        self.availableQuizzes = [NSMutableArray array];
        
        for (NSString *quizPath in dictionary[@"quizzes"]) {
            
            NSURL *quizURL = [NSURL URLWithString:quizPath];
            NSURL *pagePath = [[TSCContentController shared] urlForCacheURL:quizURL];
            
            if (pagePath) {
                NSData *pageData = [NSData dataWithContentsOfURL:pagePath];
                NSDictionary *pageDictionary = [NSJSONSerialization JSONObjectWithData:pageData options:kNilOptions error:nil];
                TSCStormObject *object = [TSCStormObject objectWithDictionary:pageDictionary parentObject:nil];
                
                if (object) {
                    [self.availableQuizzes addObject:object];
                }
            }
        }
        
        [self updateLink];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TSC_showNextAvailableQuiz:) name:OPEN_NEXT_QUIZ_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TSC_handleQuizCompleted) name:QUIZ_COMPLETED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:BADGES_CLEARED_NOTIFICATION object:nil];
    }
    
    return self;
}

- (void)updateLink
{
    self.link = [[TSCLink alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"cache://pages/%@.json", [self TSC_nextAvailableQuiz].quizId]]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPEN_NEXT_QUIZ_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QUIZ_COMPLETED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BADGES_CLEARED_NOTIFICATION object:nil];
}

- (void)TSC_handleQuizCompleted
{
    [self updateLink];
    [self reloadData];
}

- (void)reloadData
{
    if ([self.parentNavigationController.visibleViewController isKindOfClass:[TSCTableViewController class]]) {
        TSCTableViewController *tableViewController = (TSCTableViewController *)self.parentNavigationController.visibleViewController;
        tableViewController.dataSource = tableViewController.dataSource;
    }
}

- (void)TSC_showNextAvailableQuiz:(NSNotification *)notification
{
    NSNumber *quizId = notification.object;
    
    BOOL previousQuizIsCurrentQuiz = NO;
    
    for (TSCQuizPage *quiz in self.availableQuizzes) {
        
        if (previousQuizIsCurrentQuiz) {
            //Open quiz
            TSCLink *link = [[TSCLink alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"cache://pages/%@.json", quiz.quizId]]];
            [self.parentNavigationController pushLink:link];
            return;
        }
        
        NSNumber *currentQuizIdNumber = [NSNumber numberWithInt:quiz.quizId.intValue];
        
        if ([currentQuizIdNumber isEqualToNumber:quizId]) {
            previousQuizIsCurrentQuiz = YES;
        }
    }
}

- (TSCQuizPage *)TSC_nextAvailableQuiz
{
    for (TSCQuizPage *availableQuiz in self.availableQuizzes) {
        if (![[TSCBadgeController sharedController] hasEarntBadgeWithId:availableQuiz.quizBadge.badgeId]) {
            return availableQuiz;
        }
    }
    
    return nil;
}

- (int)TSC_numberOfQuizzesCompleted
{
    int i = 0;
    
    for (TSCQuizPage *availableQuiz in self.availableQuizzes) {
        
        if ([[TSCBadgeController sharedController] hasEarntBadgeWithId:availableQuiz.quizBadge.badgeId]) {
            i++;
        }
    }
    
    return i;
}

- (Class)tableViewCellClass
{
    return [TSCProgressListItemViewCell class];
}

- (TSCProgressListItemViewCell *)tableViewCell:(TSCProgressListItemViewCell *)cell;
{
    
    BOOL allQuizzesCompleted = [self TSC_numberOfQuizzesCompleted] == self.availableQuizzes.count;
    cell.nextLabel.text = allQuizzesCompleted ? @"" : [NSString stringWithLocalisationKey:@"_QUIZ_BUTTON_NEXT" fallbackString:@"Next"];
    cell.testNameLabel.text = allQuizzesCompleted ? [NSString stringWithLocalisationKey:@"_TEST_COMPLETE" fallbackString:@"Completed"] : [self TSC_nextAvailableQuiz].quizTitle;
    
    if([[TSCStormLanguageController sharedController] isRightToLeft]){
        cell.quizCountLabel.text = [NSString stringWithFormat:@" %lu / %d ", (unsigned long)self.availableQuizzes.count, [self TSC_numberOfQuizzesCompleted]];
    } else {
        cell.quizCountLabel.text = [NSString stringWithFormat:@" %d / %lu ", [self TSC_numberOfQuizzesCompleted], (unsigned long)self.availableQuizzes.count];
    }
    
    if (allQuizzesCompleted) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    self.parentNavigationController = cell.parentViewController.navigationController;
    
    return cell;
}

- (CGFloat)tableViewCellHeightConstrainedToSize:(CGSize)contrainedSize
{
    return 44;
}

- (BOOL)shouldDisplaySelectionIndicator
{
    return !([self TSC_numberOfQuizzesCompleted] == self.availableQuizzes.count);
}

@end
