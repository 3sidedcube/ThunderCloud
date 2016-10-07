//
//  TSCCollectionListItemView.m
//  ThunderCloud
//
//  Created by Sam Houghton on 09/04/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import "TSCCollectionListItem.h"
#import "TSCQuizPage.h"
#import "ThunderCloud/ThunderCloud-Swift.h"
#import "TSCQuizBadgeScrollerViewCell.h"
#import "TSCQuizCompletionViewController.h"
#import "TSCAppCollectionCell.h"
#import "TSCAppCollectionItem.h"
#import "TSCLinkCollectionItem.h"
#import "TSCLinkCollectionCell.h"
#import "TSCBadgeController.h"
#import "ThunderCloud/ThunderCloud-Swift.h"

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
                
                self.type = TSCCollectionListItemViewQuizShowcase;
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
            } else if ([collectionCells[0][@"class"] isEqualToString:@"BadgeCollectionCell"] || [collectionCells[0][@"class"] isEqualToString:@"BadgeCollectionItem"]) {
                
                self.type = TSCCollectionListItemViewBadgeShowcase;
                [self loadBadgeCells:collectionCells];
            }
        }
    }
    
    return self;
}

- (CGFloat)tableViewCellHeightConstrainedToSize:(CGSize)contrainedSize;
{
    if (self.type == TSCCollectionListItemViewQuizShowcase) {
        return 180;
    } else if (self.type == TSCCollectionListItemViewAppShowcase) {
        return 130;
    } else if (self.type == TSCCollectionListItemViewLinkShowcase) {
        return 120;
    } else if (self.type == TSCCollectionListItemViewBadgeShowcase) {
        return 192;
    }
    
    return 160;
}

- (Class)tableViewCellClass
{
    if (self.type == TSCCollectionListItemViewQuizShowcase) {
        return [[TSCStormObject classForClassKey:NSStringFromClass([TSCQuizBadgeScrollerViewCell class])] isSubclassOfClass:[UITableViewCell class]] ? [TSCStormObject classForClassKey:NSStringFromClass([TSCQuizBadgeScrollerViewCell class])] : [TSCQuizBadgeScrollerViewCell class];
    } else if (self.type == TSCCollectionListItemViewAppShowcase) {
        return [[TSCStormObject classForClassKey:NSStringFromClass([TSCAppCollectionCell class])] isSubclassOfClass:[UITableViewCell class]] ? [TSCStormObject classForClassKey:NSStringFromClass([TSCAppCollectionCell class])] : [TSCAppCollectionCell class];
    } else if (self.type == TSCCollectionListItemViewLinkShowcase) {
        return [[TSCStormObject classForClassKey:NSStringFromClass([TSCLinkCollectionCell class])] isSubclassOfClass:[UITableViewCell class]] ? [TSCStormObject classForClassKey:NSStringFromClass([TSCLinkCollectionCell class])] : [TSCLinkCollectionCell class];
    } else if (self.type == TSCCollectionListItemViewBadgeShowcase) {
        return [[TSCStormObject classForClassKey:NSStringFromClass([TSCBadgeScrollerViewCell class])] isSubclassOfClass:[UITableViewCell class]] ? [TSCStormObject classForClassKey:NSStringFromClass([TSCBadgeScrollerViewCell class])] : [TSCBadgeScrollerViewCell class];
    }
    
    return [super tableViewCellClass];
}

- (UITableViewCell *)tableViewCell:(UITableViewCell *)cell;
{
    if (self.type == TSCCollectionListItemViewQuizShowcase) {
        
        TSCQuizBadgeScrollerViewCell *scrollerCell = (TSCQuizBadgeScrollerViewCell *)cell;
        
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
        
    } else if (self.type == TSCCollectionListItemViewBadgeShowcase) {
        
        TSCBadgeScrollerViewCell *scrollerCell = (TSCBadgeScrollerViewCell *)cell;
        
        if ([scrollerCell respondsToSelector:@selector(setBadges:)]) {
            scrollerCell.badges = self.badges;
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
        
        if (quizCell[@"quiz"] && [quizCell[@"quiz"] isKindOfClass:[NSDictionary class]] && [quizCell[@"quiz"][@"destination"] isKindOfClass:[NSString class]]) {
            
            NSString *quizPath = quizCell[@"quiz"][@"destination"];
            
            NSURL *quizURL = [NSURL URLWithString:quizPath];
            NSURL *pagePath = [[ContentController shared] urlForCacheURL:quizURL];
            
            if (pagePath) {

                NSData *pageData = [NSData dataWithContentsOfURL:pagePath];
            
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
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleQuizCompletion) name:QUIZ_COMPLETED_NOTIFICATION object:nil];
}

- (void)loadBadgeCells:(NSArray *)badgeCells
{
    self.badges = [NSMutableArray array];
    
    for (NSDictionary *badgeCell in badgeCells) {
        
        NSString *badgeId = badgeCell[@"badgeId"];
        if (badgeId && [badgeId isKindOfClass:[NSString class]]) {
            
            TSCBadge *badge = [[TSCBadgeController sharedController] badgeForId:badgeId];
            if (badge) {
                [self.badges addObject:badge];
            }
            
        } else if (badgeId && [badgeId isKindOfClass:[NSNumber class]]) {
            
            TSCBadge *badge = [[TSCBadgeController sharedController] badgeForId:[NSString stringWithFormat:@"%@", badgeId]];
            if (badge) {
                [self.badges addObject:badge];
            }
        }
    }
}

- (void)handleQuizCompletion
{
    if ([self.parentNavigationController.visibleViewController isKindOfClass:[TSCTableViewController class]]) {
        TSCTableViewController *tableViewController = (TSCTableViewController *)self.parentNavigationController.visibleViewController;
        [tableViewController.tableView reloadData];
    }
}

@end
