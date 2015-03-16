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
#import "TSCBadgeController.h"

@interface TSCCollectionListItem ()

@property (nonatomic, strong) NSMutableArray *quizzes;

@end

@implementation TSCCollectionListItem

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QUIZ_COMPLETED_NOTIFICATION object:nil];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject
{
    if (self = [super initWithDictionary:dictionary parentObject:parentObject]) {
        
        NSArray *collectionCells = (NSArray *)dictionary[@"cells"];
        self.objects = [NSMutableArray array];
        
        if (collectionCells.count > 0) {
            
            if ([collectionCells[0][@"class"] isEqualToString:@"QuizCollectionItem"] || [collectionCells[0][@"class"] isEqualToString:@"QuizCollectionCell"]) {
                
                self.type = TSCCollectionListItemViewQuizBadgeShowcase;
                [self loadQuizzesQuizCells:collectionCells];
                
            } else if ([collectionCells[0][@"class"] isEqualToString:@"AppCollectionItem"] || [collectionCells[0][@"class"] isEqualToString:@"AppCollectionCell"]){
                
                self.type = TSCCollectionListItemViewAppShowcase;
                
                for (NSDictionary *appDictionary in dictionary[@"cells"]){
                    
                    TSCAppCollectionItem *item = [[TSCAppCollectionItem alloc] initWithDictionary:appDictionary];
                    [self.objects addObject:item];
                    
                }
                
            } else if ([collectionCells[0][@"class"] isEqualToString:@"LinkCollectionItem"] || [collectionCells[0][@"class"] isEqualToString:@"LinkCollectionCell"]) {
                
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
        return 180;
    } else if (self.type == TSCCollectionListItemViewAppShowcase) {
        return 130;
    } else if (self.type == TSCCollectionListItemViewLinkShowcase) {
        return 120;
    }
    
    return 160;
}

- (Class)tableViewCellClass
{
    if (self.type == TSCCollectionListItemViewQuizBadgeShowcase) {
        return [[TSCStormObject classForClassKey:NSStringFromClass([TSCBadgeScrollerViewCell class])] isSubclassOfClass:[UITableViewCell class]] ? [TSCStormObject classForClassKey:NSStringFromClass([TSCBadgeScrollerViewCell class])] : [TSCBadgeScrollerViewCell class];
    } else if (self.type == TSCCollectionListItemViewAppShowcase) {
        return [[TSCStormObject classForClassKey:NSStringFromClass([TSCAppCollectionCell class])] isSubclassOfClass:[UITableViewCell class]] ? [TSCStormObject classForClassKey:NSStringFromClass([TSCAppCollectionCell class])] : [TSCAppCollectionCell class];
    } else if (self.type == TSCCollectionListItemViewLinkShowcase) {
        return [[TSCStormObject classForClassKey:NSStringFromClass([TSCLinkCollectionCell class])] isSubclassOfClass:[UITableViewCell class]] ? [TSCStormObject classForClassKey:NSStringFromClass([TSCLinkCollectionCell class])] : [TSCLinkCollectionCell class];
    }
    
    return [super tableViewCellClass];
}

- (UITableViewCell *)tableViewCell:(UITableViewCell *)cell;
{
    if (self.type == TSCCollectionListItemViewQuizBadgeShowcase) {
        
        TSCBadgeScrollerViewCell *scrollerCell = (TSCBadgeScrollerViewCell *)cell;
        
        if ([scrollerCell respondsToSelector:@selector(setBadges:)]) {
            scrollerCell.badges = self.badges;
        }
        
        if ([scrollerCell respondsToSelector:@selector(setQuizzes:)]) {
            scrollerCell.quizzes = self.quizzes;
        }
        
        if ([scrollerCell respondsToSelector:@selector(setParentNavigationController:)]) {
            self.parentNavigationController = scrollerCell.parentViewController.navigationController;
        }
        
        return scrollerCell;
    } else if(self.type == TSCCollectionListItemViewAppShowcase) {
        
        TSCAppCollectionCell *scrollerCell = (TSCAppCollectionCell *)cell;
        
        if ([scrollerCell respondsToSelector:@selector(setApps:)]) {
            scrollerCell.apps = self.objects;
        }
        
        if ([scrollerCell respondsToSelector:@selector(setParentNavigationController:)]) {
            self.parentNavigationController = scrollerCell.parentViewController.navigationController;
        }
        return scrollerCell;
        
    } else if (self.type == TSCCollectionListItemViewLinkShowcase) {
        
        TSCLinkCollectionCell *scrollerCell = (TSCLinkCollectionCell *)cell;
        
        if ([scrollerCell respondsToSelector:@selector(setLinks:)]) {
            scrollerCell.links = self.objects;
        }
        
        if ([scrollerCell respondsToSelector:@selector(setParentNavigationController:)]) {
            self.parentNavigationController = scrollerCell.parentViewController.navigationController;
        }
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

- (void)loadQuizzesQuizCells:(NSArray *)quizCells
{
    self.badges = [NSMutableArray array];
    self.quizzes = [NSMutableArray array];
    
    for (NSDictionary *quizCell in quizCells) {
        
        NSString *quizURL = quizCell[@"quiz"][@"destination"];
        
        NSString *pagePath = [[TSCContentController sharedController] pathForCacheURL:[NSURL URLWithString:quizURL]];
        NSData *pageData = [NSData dataWithContentsOfFile:pagePath];
        
        if (pageData) {
            NSDictionary *pageDictionary = [NSJSONSerialization JSONObjectWithData:pageData options:kNilOptions error:nil];
            TSCStormObject *object = [TSCStormObject objectWithDictionary:pageDictionary parentObject:nil];
            
            if (object) {
                
                NSString *badgeId = [NSString stringWithFormat:@"%@",quizCell[@"badgeId"]];
                [self.badges addObject:[[TSCBadgeController sharedController] badgeForId:badgeId]];
                ((TSCQuizPage *)object).quizBadge = [[TSCBadgeController sharedController] badgeForId:badgeId];
                [self.quizzes addObject:((TSCQuizPage *)object)];
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
