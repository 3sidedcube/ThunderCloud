//
//  TSCQuizBadgeShowcaseView.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 26/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCQuizBadgeShowcase.h"
#import "TSCQuizPage.h"
#import "TSCQuizBadgeScrollerViewCell.h"
#import "TSCQuizCompletionViewController.h"
#import "ThunderCloud/ThunderCloud-Swift.h"

@interface TSCQuizBadgeShowcase ()

@property (nonatomic, strong) NSMutableArray *quizzes;

@end

@implementation TSCQuizBadgeShowcase

- (instancetype)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject
{
    if (self = [super initWithDictionary:dictionary parentObject:parentObject]) {
        
        self.badges = [NSMutableArray array];
        self.quizzes = [NSMutableArray array];
        
        for (NSString *quizURL in dictionary[@"quizzes"]) {
            
            NSURL *pagePath = [[TSCContentController shared] urlForCacheURL:[NSURL URLWithString:quizURL]];
            
            if (pagePath) {
                
                NSData *pageData = [NSData dataWithContentsOfURL:pagePath];
                
                if (pageData) {
                    
                    NSDictionary *pageDictionary = [NSJSONSerialization JSONObjectWithData:pageData options:kNilOptions error:nil];
                    TSCStormObject *object = [TSCStormObject objectWithDictionary:pageDictionary parentObject:nil];
                    
                    if (object) {
                        [self.badges addObject:((TSCQuizPage *)object).quizBadge];
                        [self.quizzes addObject:((TSCQuizPage *)object)];
                    }
                }
            }
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleQuizCompletion) name:QUIZ_COMPLETED_NOTIFICATION object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QUIZ_COMPLETED_NOTIFICATION object:nil];
}

- (void)handleQuizCompletion
{
    if ([self.parentNavigationController.visibleViewController isKindOfClass:[TSCTableViewController class]]) {
        TSCTableViewController *tableViewController = (TSCTableViewController *)self.parentNavigationController.visibleViewController;
        [tableViewController.tableView reloadData];
    }
}

- (CGFloat)tableViewCellHeightConstrainedToSize:(CGSize)contrainedSize;
{
    return 160;
}

- (Class)tableViewCellClass
{
    Class cellClass = [[TSCStormObject classForClassKey:NSStringFromClass([TSCQuizBadgeScrollerViewCell class])] isSubclassOfClass:[UITableViewCell class]] ? [TSCStormObject classForClassKey:NSStringFromClass([TSCQuizBadgeScrollerViewCell class])] : [TSCQuizBadgeScrollerViewCell class] ;
    return cellClass;
}

- (UITableViewCell *)tableViewCell:(UITableViewCell *)cell;
{
    TSCQuizBadgeScrollerViewCell *scrollerCell = (TSCQuizBadgeScrollerViewCell *)cell;
    
    if ([cell respondsToSelector:@selector(setBadges:)]) {
        scrollerCell.badges = self.badges;
    }
    
    if ([cell respondsToSelector:@selector(setQuizzes:)]) {
        scrollerCell.quizzes = self.quizzes;
    }
    
    if ([cell respondsToSelector:@selector(setParentNavigationController:)]) {
        self.parentNavigationController = scrollerCell.parentViewController.navigationController;
    }
    
    return scrollerCell;
}

- (BOOL)shouldDisplaySelectionCell
{
    return NO;
}

- (BOOL)shouldDisplaySelectionIndicator
{
    return NO;
}

@end
