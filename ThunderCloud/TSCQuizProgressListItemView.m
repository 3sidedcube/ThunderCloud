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
#import "TSCContentController.h"
#import "TSCBadgeController.h"
#import "UINavigationController+TSCNavigationController.h"

@implementation TSCQuizProgressListItemView

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    
    if (self) {
                
        self.availableQuizzes = [NSMutableArray array];
        
        for (NSString *quizURL in dictionary[@"quizzes"]) {
            
            NSString *pagePath = [[TSCContentController sharedController] pathForCacheURL:[NSURL URLWithString:quizURL]];
            NSData *pageData = [NSData dataWithContentsOfFile:pagePath];
            NSDictionary *pageDictionary = [NSJSONSerialization JSONObjectWithData:pageData options:kNilOptions error:nil];
            TSCStormObject *object = [TSCStormObject objectWithDictionary:pageDictionary parentObject:nil];
            
            if (object) {
                [self.availableQuizzes addObject:object];
            }
            
        }
        
        [self updateLink];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(TSC_showNextAvailableQuiz:)
         name:OPEN_NEXT_QUIZ_NOTIFICATION
         object:nil];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(TSC_handleQuizCompleted)
         name:QUIZ_COMPLETED_NOTIFICATION
         object:nil];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(reloadData)
         name:BADGES_CLEARED_NOTIFICATION
         object:nil];
    }
    
    return self;
}

- (void)updateLink {
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
        [tableViewController.tableView reloadData];
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
    cell.nextLabel.text = [self TSC_numberOfQuizzesCompleted] == self.availableQuizzes.count ? @"" : (TSCLanguageString(@"_QUIZ_BUTTON_NEXT") ? TSCLanguageString(@"_QUIZ_BUTTON_NEXT") : @"Next");
    cell.testNameLabel.text = [self TSC_numberOfQuizzesCompleted] == self.availableQuizzes.count ? (TSCLanguageString(@"_TEST_COMPLETE") ? TSCLanguageString(@"_TEST_COMPLETE") : @"Completed") : [self TSC_nextAvailableQuiz].quizTitle;
    cell.quizCountLabel.text = [NSString stringWithFormat:@" %d / %lu ", [self TSC_numberOfQuizzesCompleted], (unsigned long)self.availableQuizzes.count];
    
    self.parentNavigationController = cell.parentViewController.navigationController;
    
    return cell;
}

- (CGFloat)tableViewCellHeightConstrainedToSize:(CGSize)contrainedSize
{
    return 44;
}

@end
