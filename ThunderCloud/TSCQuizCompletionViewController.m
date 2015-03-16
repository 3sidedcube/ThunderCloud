//
//  TSCQuizCompletionViewController.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 12/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@import ThunderBasics;
#import "TSCQuizCompletionViewController.h"
#import "TSCAchievementDisplayView.h"
#import "TSCQuizItem.h"
#import "TSCBadge.h"
#import "UIView+Pop.h"
#import "TSCListItem.h"
#import "TSCSplitViewController.h"
#import "TSCBadgeController.h"
#import "TSCImage.h"
#import "UINavigationController+TSCNavigationController.h"
#import "NSString+LocalisedString.h"
#import "TSCStormTableRow.h"

#define STORM_QUIZ_KEY @"TSCCompletedQuizes"
#define STORM_RATE_AFTER_QUIZ_SHOWN @"TSCQuizRate"

@interface TSCQuizCompletionViewController ()

@property (nonatomic, strong) TSCAchievementDisplayView *displayView;
@property (nonatomic, strong) UIView *successView;

@end

@implementation TSCQuizCompletionViewController

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    [self setupLeftNavigationBarButtons];
    [self.tableView reloadData];
}

- (id)initWithQuizPage:(TSCQuizPage *)quizPage questions:(NSArray *)questions
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        
        self.questions = questions;
        self.quizPage = quizPage;
        self.title = quizPage.title;
        
        [self.navigationItem setHidesBackButton:YES animated:YES];
        
        if (isPad()) {
            
            self.navigationItem.leftBarButtonItem = [TSCSplitViewController sharedController].menuButton;
        }
        
        self.navigationItem.rightBarButtonItem = [self rightBarButtonItem];
        
        if ([self quizIsCorrect]) {
            self.navigationItem.leftBarButtonItems = [self additionalLeftBarButtonItems];
            
            // THESE MUST OCCUR IN THIS ORDER!
            [self markQuizAsComplete:self.quizPage];
            [[NSNotificationCenter defaultCenter] postNotificationName:QUIZ_COMPLETED_NOTIFICATION object:nil];
            
            [self setupLeftNavigationBarButtons];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCStatEventNotification" object:self userInfo:@{@"type":@"event", @"category":@"Quiz", @"action":[NSString stringWithFormat:@"Won %@ badge", quizPage.title]}];
            
        } else {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCStatEventNotification" object:self userInfo:@{@"type":@"event", @"category":@"Quiz", @"action":[NSString stringWithFormat:@"Lost %@ badge", quizPage.title]}];
        }
    }
    
    return self;
}

-(NSArray *)additionalLeftBarButtonItems
{
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithLocalisationKey:@"_QUIZ_BUTTON_SHARE" fallbackString:@"Share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareBadge:)];
    return @[shareButton];
}

-(UIBarButtonItem *)rightBarButtonItem
{
    UIBarButtonItem *finishButton = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithLocalisationKey:@"_QUIZ_BUTTON_FINISH" fallbackString:@"Finish"] style:UIBarButtonItemStylePlain target:self action:@selector(finishQuiz:)];
    return finishButton;
}

- (void)setupLeftNavigationBarButtons
{
    if (isPad()) {
        
        NSMutableArray *leftItems = [NSMutableArray new];
        if (isPad()) {
            if ([TSCSplitViewController sharedController].menuButton) {
                [leftItems addObject:[TSCSplitViewController sharedController].menuButton];
            }
        }
        
        if ([self quizIsCorrect]) {
            [leftItems addObjectsFromArray:[self additionalLeftBarButtonItems]];
        }
        if (leftItems.count > 0) {
            self.navigationItem.leftBarButtonItems = leftItems;
        }
        else {
            self.navigationItem.leftBarButtonItems = nil;
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BOOL linkRowsContainTableRows = NO;
    
    if (![self quizIsCorrect]) {
        
        NSMutableArray *sections = [NSMutableArray new];
        
        if (self.quizPage.loseMessage) {
            TSCStormTableRow *fail = [TSCStormTableRow rowWithTitle:self.quizPage.loseMessage];
            TSCTableSection *failSection = [TSCTableSection sectionWithItems:@[fail]];
            [sections addObject:failSection];
        }
        
        TSCTableSection *questionSection = [TSCTableSection sectionWithItems:self.questions];
        [sections addObject:questionSection];
        
        TSCStormTableRow *tryAgainRow = [TSCStormTableRow rowWithTitle:[NSString stringWithLocalisationKey:@"_QUIZ_BUTTON_AGAIN" fallbackString:@"Try again?"]];
        
        TSCTableSection *tryAgainSection = [TSCTableSection sectionWithTitle:nil footer:nil items:@[tryAgainRow] target:self selector:@selector(handleRetry:)];
        [sections addObject:tryAgainSection];
        
        if (self.quizPage.loseRelatedLinks.count > 0) {
            
            BOOL linkRowsContainTableRows = NO;
            NSMutableArray *linkRows = [NSMutableArray array];
            
            for (TSCLink *link in self.quizPage.loseRelatedLinks) {
                
                NSObject *linkRow = [[self class] rowForRelatedLink:link correctQuiz:[self quizIsCorrect]];
                
                if ([linkRow isKindOfClass:[TSCTableRow class]]) {
                    TSCStormTableRow *tableRow = (TSCStormTableRow *)linkRow;
                    tableRow.selector = @selector(loseRelatedLinkTapped:);
                    tableRow.target = self;
                    linkRow = tableRow;
                    linkRowsContainTableRows = YES;
                }
                
                if ([linkRow respondsToSelector:@selector(parentObject)]) {
                    TSCStormObject *object = (TSCStormObject *)linkRow;
                    object.parentObject = self;
                    linkRow = object;
                }
                
                [linkRows addObject:linkRow];
            }
            
            NSString *title = [NSString stringWithLocalisationKey:@"_QUIZ_COMPLETION_TITLE_LINKS" fallbackString:@"Related Links"];
            
            if (!linkRowsContainTableRows) {
                title = @"";
            }
            
            TSCTableSection *relatedLinks = [TSCTableSection sectionWithTitle:title footer:nil items:linkRows target:nil selector:nil];
            [sections addObject:relatedLinks];
            
            
        }
        
        self.dataSource = sections;
        
    } else {
        
        self.tableView.scrollEnabled = YES;
        
        Class achievementDisplayViewClass = [TSCStormObject classForClassKey:NSStringFromClass([TSCAchievementDisplayView class])];
        self.displayView = [[achievementDisplayViewClass alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300) image:[TSCImage imageWithDictionary:self.quizPage.quizBadge.badgeIcon] subtitle:self.quizPage.winMessage];
        
        if (self.quizPage.winRelatedLinks.count > 0) {
            self.tableView.scrollEnabled = YES;
            self.tableView.tableHeaderView = _displayView;
            
            NSMutableArray *linkRows = [NSMutableArray array];
            
            for (TSCLink *link in self.quizPage.winRelatedLinks) {
                
                NSObject *linkRow = [[self class] rowForRelatedLink:link correctQuiz:[self quizIsCorrect]];
                
                if ([linkRow conformsToProtocol:@protocol(TSCTableRowDataSource)]) {
                    
                    TSCTableRow *tableRow = (TSCTableRow *)linkRow;
                    
                    if ([tableRow respondsToSelector:@selector(setSelector:)]) {
                        
                        tableRow.selector = @selector(winRelatedLinkTapped:);
                        tableRow.target = self;
                    }
                    linkRow = tableRow;
                    
                    linkRowsContainTableRows = YES;
                }
                
                [linkRows addObject:linkRow];
            }
            
            NSString *title = [NSString stringWithLocalisationKey:@"_QUIZ_COMPLETION_TITLE_LINKS" fallbackString:@"Related Links"];
            
            if (!linkRowsContainTableRows) {
                title = @"";
            }
            
            TSCTableSection *relatedLinks = [TSCTableSection sectionWithTitle:title footer:nil items:linkRows target:nil selector:nil];
            self.dataSource = @[relatedLinks];
            
        } else {
            [self.view addSubview:_displayView];
        }
    }
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.1)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (isPad() && !self.presentingViewController) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

+(NSObject *)rowForRelatedLink:(TSCLink *)link correctQuiz:(BOOL)correctQuiz
{
    TSCTableRow *linkRow = [TSCTableRow rowWithTitle:link.title];
    return linkRow;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_displayView popIn];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.displayView.frame = CGRectMake(0, 0, self.view.frame.size.width, 400);
    
    //self.displayView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.displayView.frame.origin.y + self.displayView.subtitleLabel.frame.size.height + self.displayView.subtitleLabel.frame.origin.y + 10);
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

#pragma mark Quiz logic

- (BOOL)quizIsCorrect
{
    int correctQuizzes = 0;
    
    for (TSCQuizItem *quiz in self.questions) {
        if (quiz.isCorrect) {
            correctQuizzes++;
        }
    }
    
    return (correctQuizzes == self.questions.count);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (![self quizIsCorrect]) {
        
        return UITableViewAutomaticDimension;
        
    } else {
        
        //No related links
        if (self.quizPage.winRelatedLinks.count < 1) {
            
            return 256;
            
            //Related links
        } else {
            
            //Is iPad
            if (isPad()) {
                
                return UITableViewAutomaticDimension;
            }
            
            return UITableViewAutomaticDimension;
        }
    }
}

#pragma mark - Navigation button handling
- (void)shareBadge:(UIBarButtonItem *)shareButton
{
    NSString *defaultShareBadgeMessage = [NSString stringWithLocalisationKey:@"_TEST_COMPLETED_SHARE" fallbackString:@"I earned this badge"];
    UIActivityViewController *shareViewController = [[UIActivityViewController alloc] initWithActivityItems:@[[TSCImage imageWithDictionary:self.quizPage.quizBadge.badgeIcon], self.quizPage.quizBadge.badgeShareMessage ? self.quizPage.quizBadge.badgeShareMessage : defaultShareBadgeMessage] applicationActivities:nil];
    shareViewController.excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll, UIActivityTypePrint, UIActivityTypeAssignToContact];
    
    if ([shareViewController respondsToSelector:@selector(popoverPresentationController)]) {
        shareViewController.popoverPresentationController.barButtonItem = shareButton;
    }
    
    [shareViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        if (completed) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCStatEventNotification" object:self userInfo:@{@"type":@"event", @"category":@"Quiz", @"action":[NSString stringWithFormat:@"Share %@ to %@", self.quizPage.title, activityType]}];
            
        }
    }];
    
    if (isPad() && ![TSCThemeManager isOS8]) {
        [[TSCSplitViewController sharedController] presentFullScreenViewController:shareViewController animated:YES];
    } else {
        [self presentViewController:shareViewController animated:YES completion:nil];
    }
}

- (void)finishQuiz:(UIBarButtonItem *)barButtonItem
{
    self.quizPage.currentIndex = 0;
    
    if (isPad()) {
        
        if(self.presentingViewController) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    if ([self quizIsCorrect]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:QUIZ_COMPLETED_NOTIFICATION object:nil];
    }
}

- (void)nextTest:(UIBarButtonItem *)barButtonItem
{
    [[NSNotificationCenter defaultCenter] postNotificationName:OPEN_NEXT_QUIZ_NOTIFICATION object:self.quizPage.quizId];
}

- (void)handleRetry:(TSCTableSelection *)selection
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCStatEventNotification" object:self userInfo:@{@"type":@"event", @"category":@"Quiz", @"action":[NSString stringWithFormat:@"Try again - %@ ", self.quizPage.title]}];
    
    TSCLink *link = [[TSCLink alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"cache://pages/%@.json", self.quizPage.quizId]]];
    [self.navigationController pushLink:link];
}

#pragma mark - Quiz handling

- (void)markQuizAsComplete:(TSCQuizPage *)quizPage
{
    [[TSCBadgeController sharedController] markBadgeAsEarnt:quizPage.quizBadge.badgeId];
    
    if ([[TSCBadgeController sharedController] earnedBadges].count > 2 && ![[NSUserDefaults standardUserDefaults] boolForKey:STORM_RATE_AFTER_QUIZ_SHOWN]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Rate this app" message:@"If you like our app, please take a moment to rate it" delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Rate", nil];
        [alertView show];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STORM_RATE_AFTER_QUIZ_SHOWN];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if ([TSCThemeManager isOS7]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"TSCItunesId"]]]];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&;amp;amp;amp;amp;mt=8", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"TSCItunesId"]]]];
        }
    }
}

#pragma mark - Related link handling

- (void)loseRelatedLinkTapped:(TSCTableSelection *)selection {
    [self.navigationController pushLink:[self.quizPage.loseRelatedLinks objectAtIndex:selection.indexPath.row]];
}

- (void)winRelatedLinkTapped:(TSCTableSelection *)selection {
    [self.navigationController pushLink:[self.quizPage.winRelatedLinks objectAtIndex:selection.indexPath.row]];
}

@end
