//
//  TSCQuizPage.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 11/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCQuizPage.h"
#import "TSCQuizItem.h"
#import "TSCTextQuizItem.h"
#import "NSString+LocalisedString.h"
#import "TSCImage.h"
#import <ThunderCloud/ThunderCloud-Swift.h>
@import ThunderBasics;
@import MobileCoreServices;

@interface TSCQuizPage () <UINavigationControllerDelegate, StormObjectProtocol>

@property (nonatomic, assign) BOOL isPushingViewController;
@property (nonatomic, assign) BOOL resetOnAppear;

@end

@implementation TSCQuizPage

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didShowViewController:) name:@"UINavigationControllerDidShowViewControllerNotification" object:nil];
        self.title = [[TSCStormLanguageController sharedController] stringForDictionary:(dictionary[@"title"])];
        
        //ID
        self.quizId = dictionary[@"id"];
		if ([self.quizId isKindOfClass:[NSNumber class]]) {
			NSNumber *quizIdNumber = (NSNumber *)self.quizId;
			self.quizId = [NSString stringWithFormat:@"%@", quizIdNumber];
		}
        
        //Title
        self.quizTitle = [[TSCStormLanguageController sharedController] stringForDictionary:(dictionary[@"title"])];
        
        //Messages
        self.winMessage = [[TSCStormLanguageController sharedController] stringForDictionary:(dictionary[@"winMessage"])];
        self.loseMessage = [[TSCStormLanguageController sharedController] stringForDictionary:(dictionary[@"loseMessage"])];
        self.shareMessage = [[TSCStormLanguageController sharedController] stringForDictionary:(dictionary[@"shareMessage"])];
        
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
		
		self.badgeId = dictionary[@"badgeId"];
		if ([self.badgeId isKindOfClass:[NSNumber class]]) {
			NSNumber *badgeIdNumber = (NSNumber *)self.badgeId;
			self.badgeId = [NSString stringWithFormat:@"%@", badgeIdNumber];
		}
        
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
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithLocalisationKey:@"_QUIZ_BUTTON_NEXT" fallbackString:@"Next"] style:UIBarButtonItemStylePlain target:self action:@selector(next)];
    }
    
    return self;
}

- (void)resetInitialPage
{
    self.resetOnAppear = true;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && self.presentingViewController) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithLocalisationKey:@"_QUIZ_BUTTON_BACK" fallbackString:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    } else if (self.presentingViewController) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithLocalisationKey:@"_QUIZ_BUTTON_DISMISS" fallbackString:@"Done"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    }
    
    // Our first question is added to the view manually like this. Subsequent questions are pushed.
    
    if ((self.questions.count && self.view.subviews.count < 1) || self.resetOnAppear) {
        
        if (self.resetOnAppear && self.initialQuizQuestion.view.superview) {
            [self.initialQuizQuestion.view removeFromSuperview];
            
        }
        
        TSCQuizItem *nextQuestion = self.questions[self.currentIndex];
       
        // Reset selectedIndexes to stop values being saved after quiz completion
        nextQuestion.selectedIndexes = [NSMutableArray new];
        
        Class class = NSClassFromString(nextQuestion.quizClass);
        
        self.initialQuizQuestion = [[class alloc] initWithQuestion:nextQuestion];
        
        self.currentViewController = self.initialQuizQuestion;
        
        self.initialQuizQuestion.view.frame = self.view.bounds;
        [self.initialQuizQuestion viewWillAppear:NO];
        
        [self.view addSubview:self.initialQuizQuestion.view];
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.resetOnAppear = false;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.currentViewController.view.frame = self.view.bounds;
}

#pragma mark TitleBar handling

- (UIView *)titleViewForNavigationBar:(NSInteger)index
{
    // UIView to contain multiple elements for navigation bar
    UIView *progressContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 140, 44)];
    
    UILabel *progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, progressContainer.bounds.size.width, 22)];
    progressLabel.textAlignment = NSTextAlignmentCenter;
    progressLabel.font = [UIFont boldSystemFontOfSize:16];
    progressLabel.textColor = [[UINavigationBar appearance] tintColor];
    progressLabel.backgroundColor = [UIColor clearColor];
    
    if ([[TSCStormLanguageController sharedController] isRightToLeft]) {
        
        progressLabel.text = [NSString stringWithFormat:@"%@ %@ %@", @(self.questions.count), [NSString stringWithLocalisationKey:@"_QUIZ_OF" fallbackString:@"of"], @(self.currentIndex + 1)];
    } else {
        
        progressLabel.text = [NSString stringWithFormat:@"%@ %@ %@", @(self.currentIndex + 1), [NSString stringWithLocalisationKey:@"_QUIZ_OF" fallbackString:@"of"], @(self.questions.count)];
    }
    
    [progressContainer addSubview:progressLabel];
    
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 22, progressContainer.bounds.size.width, 22)];
    progressView.progressTintColor = [TSCThemeManager sharedManager].theme.progressTintColour;
    progressView.trackTintColor = [TSCThemeManager sharedManager].theme.progressTrackTintColour;
    progressView.progress = 0;
    
    if ([[TSCStormLanguageController sharedController] isRightToLeft]) {
        
        CGAffineTransform transform = CGAffineTransformMake(1, 0, 0, -1, 0, progressView.frame.size.height);
        transform = CGAffineTransformRotate(transform, M_PI);
        progressView.transform = transform;
    }
    
    progressView.progressViewStyle = UIProgressViewStyleDefault;
    progressView.progress = ((float)index / (float)self.questions.count);
    
    [progressView setY:progressView.frame.origin.y + 10];
    progressView.transform = CGAffineTransformMakeScale(1.0, 3.0);
    
    [progressContainer addSubview:progressView];
    
    UIView *progressStartCap = [[UIView alloc] initWithFrame:CGRectMake(progressView.frame.origin.x - 2, progressView.frame.origin.y, 6, 6)];
    progressStartCap.layer.cornerRadius = 3.0f;
    progressStartCap.backgroundColor = progressView.progressTintColor;
    [progressContainer addSubview:progressStartCap];
    
    UIView *progressEndCap = [[UIView alloc] initWithFrame:CGRectMake(progressView.frame.origin.x + progressView.frame.size.width - 3, progressView.frame.origin.y, 6, 6)];
    progressEndCap.layer.cornerRadius = 3.0f;
    progressEndCap.backgroundColor = progressView.trackTintColor;
    [progressContainer addSubview:progressEndCap];
    [progressContainer sendSubviewToBack:progressEndCap];
    
    return progressContainer;
}

#pragma mark Navigation Handling

- (void)next
{
    if(!self.isPushingViewController) {
        
        self.isPushingViewController = YES;
        
        if (self.currentIndex != self.questions.count - 1) {
            
            //Increment index
            self.currentIndex++;
            
            //Get question
            TSCQuizItem *nextQuestion = self.questions[self.currentIndex];
            
            Class class = NSClassFromString(nextQuestion.quizClass);
            
            UIViewController *quizQuestion = [[class alloc] initWithQuestion:nextQuestion];
            nextQuestion.selectedIndexes = [NSMutableArray new];
            
            quizQuestion.navigationItem.titleView = [self titleViewForNavigationBar:self.currentIndex + 1];
            quizQuestion.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithLocalisationKey:@"_QUIZ_BUTTON_NEXT" fallbackString:@"Next"] style:UIBarButtonItemStylePlain target:self action:@selector(next)];
            quizQuestion.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithLocalisationKey:@"_QUIZ_BUTTON_BACK" fallbackString:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
            
            self.currentViewController = quizQuestion;
            
            [self.navigationController pushViewController:quizQuestion animated:YES];
            
        } else {
            
            Class quizClass = [[TSCStormObjectFactory sharedFactory] classForClassKey:@"TSCQuizCompletionViewController"];
            UIViewController *completedQuiz = [[quizClass alloc] initWithQuizPage:self questions:self.questions];
            [self.navigationController pushViewController:completedQuiz animated:YES];
        }
    }
}

- (void)back
{
    if (self.currentIndex > 0) {
        
        self.currentIndex--;
        if(self.currentIndex == 0) {
            self.currentViewController = self.initialQuizQuestion;
        } else {
            self.currentViewController = self.navigationController.viewControllers[self.currentIndex + 1];
        }
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:true completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didShowViewController:(NSNotification *)notification
{
    self.isPushingViewController = NO;
}

- (CSSearchableItemAttributeSet *)searchableAttributeSet
{
    CSSearchableItemAttributeSet *searchableAttributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString *)kUTTypeData];
    searchableAttributeSet.title = self.quizTitle;
	
	if (!self.badgeId) {
		return searchableAttributeSet;
	}
	
	TSCBadge *badge = [[TSCBadgeController sharedController] badgeFor:self.badgeId];
	
    if (badge.icon) {
        searchableAttributeSet.thumbnailData = UIImagePNGRepresentation(badge.icon);
    }
	
    return searchableAttributeSet;
}

@end
