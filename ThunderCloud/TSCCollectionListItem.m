//
//  TSCCollectionListItemView.m
//  ThunderCloud
//
//  Created by Sam Houghton on 09/04/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import "TSCCollectionListItem.h"
#import "TSCQuizController.h"
#import "TSCQuizPage.h"
#import "TSCContentController.h"
#import "TSCBadgeScrollerViewCell.h"
#import "TSCQuizCompletionViewController.h"
#import "TSCAppCollectionCell.h"
#import "TSCAppCollectionItem.h"
#import "TSCLinkCollectionItem.h"
#import "TSCLinkCollectionCell.h"

@interface TSCCollectionListItem ()

@end

@implementation TSCCollectionListItem

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QUIZ_COMPLETED_NOTIFICATION object:nil];
}

- (id)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject
{
    if (self = [super initWithDictionary:dictionary parentObject:parentObject]) {
        
        NSArray *collectionCells = (NSArray *)dictionary[@"cells"];
        self.objects = [NSMutableArray array];
        
        if (collectionCells.count > 0) {
            
            if ([collectionCells[0][@"class"] isEqualToString:@"QuizCollectionItem"]) {
                
                self.type = TSCCollectionListItemViewQuizBadgeShowcase;
                [self loadQuizzesQuizCells:collectionCells];
                
            } else if ([collectionCells[0][@"class"] isEqualToString:@"AppCollectionItem"]){
                
                self.type = TSCCollectionListItemViewAppShowcase;
                
                for (NSDictionary *appDictionary in dictionary[@"cells"]){
                    
                    TSCAppCollectionItem *item = [[TSCAppCollectionItem alloc] initWithDictionary:appDictionary];
                    [self.objects addObject:item];
                    
                }
                
            } else if ([collectionCells[0][@"class"] isEqualToString:@"LinkCollectionItem"]) {
                
                self.type = TSCCollectionListItemViewLinkShowcase;
                
                for (NSDictionary *linkDictionary in dictionary[@"cells"]) {
                    
                    TSCLinkCollectionItem *item = [[TSCLinkCollectionItem alloc] initWithDictionary:linkDictionary];
                    [self.objects addObject:item];
                }
            }
            
        }
    }
    
    return self;
}

- (CGFloat)tableViewCellHeightConstrainedToSize:(CGSize)contrainedSize;
{
    if (self.type == TSCCollectionListItemViewQuizBadgeShowcase) {
        return 160;
    } else if (self.type == TSCCollectionListItemViewAppShowcase) {
        return 100;
    } else if (self.type == TSCCollectionListItemViewLinkShowcase) {
        return 120;
    }
    
    return 160;
}

- (Class)tableViewCellClass
{
    if (self.type == TSCCollectionListItemViewQuizBadgeShowcase) {
        return [TSCBadgeScrollerViewCell class];
    } else if (self.type == TSCCollectionListItemViewAppShowcase) {
        return [TSCAppCollectionCell class];
    } else if (self.type == TSCCollectionListItemViewLinkShowcase) {
        return [TSCLinkCollectionCell class];
    }
    
    return [super tableViewCellClass];
}

- (UITableViewCell *)tableViewCell:(UITableViewCell *)cell;
{
    if (self.type == TSCCollectionListItemViewQuizBadgeShowcase) {
        TSCBadgeScrollerViewCell *scrollerCell = (TSCBadgeScrollerViewCell *)cell;
        scrollerCell.badges = self.badges;
        self.parentNavigationController = scrollerCell.parentViewController.navigationController;
        
        return scrollerCell;
    } else if(self.type == TSCCollectionListItemViewAppShowcase) {
        
        TSCAppCollectionCell *scrollerCell = (TSCAppCollectionCell *)cell;
        scrollerCell.apps = self.objects;
        self.parentNavigationController = scrollerCell.parentViewController.navigationController;
        return scrollerCell;
        
    } else if (self.type == TSCCollectionListItemViewLinkShowcase) {
        
        TSCLinkCollectionCell *scrollerCell = (TSCLinkCollectionCell *)cell;
        scrollerCell.links = self.objects;
        self.parentNavigationController = scrollerCell.parentViewController.navigationController;
        return scrollerCell;
    }
    
    return [super tableViewCell:cell];
}

- (BOOL)shouldDisplaySelectionCell
{
    return NO;
}

- (BOOL)shouldDisplaySelectionIndicator
{
    return NO;
}

#pragma mark - Quiz cell overrides

- (void)loadQuizzesQuizCells:(NSArray *)quizCells {
    self.badges = [NSMutableArray array];
    
    for (NSDictionary *quizCell in quizCells) {
        
        NSString *quizURL = [NSString stringWithFormat:@"cache://pages/%@.json", quizCell[@"quizId"]];
        
        NSString *pagePath = [[TSCContentController sharedController] pathForCacheURL:[NSURL URLWithString:quizURL]];
        NSData *pageData = [NSData dataWithContentsOfFile:pagePath];
        if(pageData){
            NSDictionary *pageDictionary = [NSJSONSerialization JSONObjectWithData:pageData options:kNilOptions error:nil];
            TSCStormObject *object = [TSCStormObject objectWithDictionary:pageDictionary parentObject:nil];
            
            if (object) {
                [self.badges addObject:((TSCQuizPage *)object).quizBadge];
            }
        }
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleQuizCompletion) name:QUIZ_COMPLETED_NOTIFICATION object:nil];
}

- (void)handleQuizCompletion
{
    if ([self.parentNavigationController.visibleViewController isKindOfClass:[TSCTableViewController class]]) {
        TSCTableViewController *tableViewController = (TSCTableViewController *)self.parentNavigationController.visibleViewController;
        [tableViewController.tableView reloadData];
    }
}
@end
