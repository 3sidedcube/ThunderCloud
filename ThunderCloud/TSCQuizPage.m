//
//  TSCQuizPage.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 11/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCQuizPage.h"
#import "TSCQuizItem.h"
#import "TSCQuizQuestionViewController.h"
#import "TSCTextQuizItem.h"
#import "TSCQuizCompletionViewController.h"
#import "TSCBadgeController.h"
#import "TSCStormObject.h"
@import ThunderBasics;

@implementation TSCQuizPage

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        
        self.title = TSCLanguageDictionary(dictionary[@"title"]);
        
        //ID
        self.quizId = dictionary[@"id"];
        
        //Title
        self.quizTitle = TSCLanguageDictionary(dictionary[@"title"]);
        
        //Messages
        self.winMessage = TSCLanguageDictionary(dictionary[@"winMessage"]);
        self.loseMessage = TSCLanguageDictionary(dictionary[@"loseMessage"]);
        self.shareMessage = TSCLanguageDictionary(dictionary[@"shareMessage"]);
        
        //Related links
        self.loseRelatedLinks = [NSMutableArray array];
        for (NSDictionary *loseDict in dictionary[@"loseRelatedLinks"]) {
            TSCLink *loseLink = [[TSCLink alloc] initWithDictionary:loseDict];
            [self.loseRelatedLinks addObject:loseLink];
        }
        
        self.winRelatedLinks = [NSMutableArray array];
        for (NSDictionary *winDict in dictionary[@"winRelatedLinks"]) {
            TSCLink *winLink = [[TSCLink alloc] initWithDictionary:winDict];
            [self.winRelatedLinks addObject:winLink];
        }
        
        //Badge        
        self.quizBadge = [[TSCBadgeController sharedController] badgeForId:dictionary[@"badgeId"]];
        
        //Questions
        self.questions = [NSMutableArray array];
        
        int i = 1;
        
        for (NSDictionary *questionDictionary in dictionary[@"children"]) { 
            
            TSCQuizItem *question = [[TSCQuizItem alloc] initWithDictionary:questionDictionary];
            question.questionNumber = i;
            [self.questions addObject:question];
            i++;
        }
        
        self.currentIndex = 0;
        
        //Navigation Bar
        self.navigationItem.titleView = [self titleViewForNavigationBar:1];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TSCLanguageString(@"_QUIZ_BUTTON_NEXT") ? TSCLanguageString(@"_QUIZ_BUTTON_NEXT") : @"Next" style:UIBarButtonItemStylePlain target:self action:@selector(next)];
        
        if (!isPad()) {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TSCLanguageString(@"_QUIZ_BUTTON_BACK") ? TSCLanguageString(@"_QUIZ_BUTTON_BACK") : @"Back" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        } else {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TSCLanguageString(@"_QUIZ_BUTTON_CANCEL") ? TSCLanguageString(@"_QUIZ_BUTTON_CANCEL") : @"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
        }
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Our first question is added to the view manually like this. Subsequent questions are pushed.
    
    if (self.questions.count && self.view.subviews.count < 1) {
        
        TSCQuizItem *nextQuestion = self.questions[self.currentIndex];
        
        Class class = NSClassFromString(nextQuestion.quizClass);
        
        self.initialQuizQuestion = [[class alloc] initWithQuestion:nextQuestion];
        
        self.currentViewController = self.initialQuizQuestion;
        
        self.initialQuizQuestion.view.frame = self.view.bounds;
        [self.initialQuizQuestion viewWillAppear:NO];
        
        [self.view addSubview:self.initialQuizQuestion.view];
       
        if ([TSCThemeManager isOS7]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.currentViewController.view.frame = self.view.frame;
    
    if (isPad()) {
        self.currentViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
}

#pragma mark TitleBar handling

- (UIView *)titleViewForNavigationBar:(NSInteger)index
{
    // UIView to contain multiple elements for navigation bar
    UIView *progressContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 140, 44)];
    
    UILabel *progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, progressContainer.bounds.size.width, 22)];
    progressLabel.textAlignment = NSTextAlignmentCenter;
    progressLabel.font = [UIFont boldSystemFontOfSize:12];
    progressLabel.textColor = [[TSCThemeManager sharedTheme] mainColor];
    progressLabel.backgroundColor = [UIColor clearColor];
    
    if ([TSCThemeManager isRightToLeft]) {
        
        progressLabel.text = [NSString stringWithFormat:@"%lu %@ %ld", (unsigned long)self.questions.count, TSCLanguageString(@"_QUIZ_OF") ? TSCLanguageString(@"_QUIZ_OF") : @"of", self.currentIndex + 1];
    } else {
        
        progressLabel.text = [NSString stringWithFormat:@"%ld %@ %lu", self.currentIndex + 1, TSCLanguageString(@"_QUIZ_OF") ? TSCLanguageString(@"_QUIZ_OF") : @"of", (unsigned long)self.questions.count];
    }
    
    [progressContainer addSubview:progressLabel];
    
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 22, progressContainer.bounds.size.width, 22)];
    progressView.progress = 0;
    
    if ([TSCThemeManager isRightToLeft]) {
        
        CGAffineTransform transform = CGAffineTransformMake(1, 0, 0, -1, 0, progressView.frame.size.height);
        transform = CGAffineTransformRotate(transform, M_PI);
        progressView.transform = transform;
    }
    
    progressView.progressViewStyle = UIProgressViewStyleDefault;
    progressView.progress = ((float)index / (float)self.questions.count);
    
    [progressContainer addSubview:progressView];

    return progressContainer;
}

#pragma mark Navigation Handling

- (void)next
{
    if (self.currentIndex != self.questions.count - 1) {
        
        //Increment index
        self.currentIndex++;
        
        //Get question
        TSCQuizItem *nextQuestion = self.questions[self.currentIndex];
        
        Class class = NSClassFromString(nextQuestion.quizClass);
        
        UIViewController *quizQuestion = [[class alloc] initWithQuestion:nextQuestion];
        
        quizQuestion.navigationItem.titleView = [self titleViewForNavigationBar:self.currentIndex + 1];
        quizQuestion.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TSCLanguageString(@"_QUIZ_BUTTON_NEXT") ? TSCLanguageString(@"_QUIZ_BUTTON_NEXT") : @"Next" style:UIBarButtonItemStylePlain target:self action:@selector(next)];
        quizQuestion.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TSCLanguageString(@"_QUIZ_BUTTON_BACK") ? TSCLanguageString(@"_QUIZ_BUTTON_BACK") : @"Back" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        
        self.currentViewController = quizQuestion;
        
        [self.navigationController pushViewController:quizQuestion animated:YES];
        
    } else {
        
        Class quizClass = [TSCStormObject classForClassKey:@"TSCQuizCompletionViewController"];
        
        UIViewController *completedQuiz = [[quizClass alloc] initWithQuizPage:self questions:self.questions];
        
        [self.navigationController pushViewController:completedQuiz animated:YES];
    }
}

- (void)back
{
    if (self.currentIndex > 0) {
        self.currentIndex--;
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
