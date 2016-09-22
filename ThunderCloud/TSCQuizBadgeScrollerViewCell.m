//
//  TSCBadgeScrollerViewCell.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 27/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCQuizBadgeScrollerViewCell.h"
#import "TSCQuizBadgeScrollerItemViewCell.h"
#import "TSCBadge.h"
#import "TSCBadgeShareViewController.h"
#import "TSCImage.h"
#import "TSCBadgeController.h"
#import "TSCQuizPage.h"
#import "TSCSplitViewController.h"
#import "TSCQuizCompletionViewController.h"
#import "NSString+LocalisedString.h"

@interface TSCBadgeScrollerFlowLayout : UICollectionViewFlowLayout

@end

@implementation TSCBadgeScrollerFlowLayout

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    return CGPointMake(proposedContentOffset.x - 100, proposedContentOffset.y);
}

@end

@implementation TSCQuizBadgeScrollerViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.collectionView registerClass:[TSCQuizBadgeScrollerItemViewCell class] forCellWithReuseIdentifier:@"Cell"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self.collectionView selector:@selector(reloadData) name:QUIZ_COMPLETED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self.collectionView selector:@selector(reloadData) name:BADGES_CLEARED_NOTIFICATION object:nil];

    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.collectionView name:QUIZ_COMPLETED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self.collectionView name:BADGES_CLEARED_NOTIFICATION object:nil];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.collectionView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    self.pageControl.frame = CGRectMake(0, self.contentView.frame.size.height - 24, self.contentView.frame.size.width, 20);
    self.pageControl.numberOfPages = ceil(self.collectionView.contentSize.width /
                                          self.collectionView.frame.size.width);
    
    self.shouldDisplaySeparators = NO;
}

#pragma mark Collection view datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.badges.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TSCBadge *badge = self.badges[indexPath.item];
    
    TSCQuizBadgeScrollerItemViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.badgeImage.image = [TSCImage imageWithJSONObject:badge.badgeIcon];
    cell.titleLabel.text = badge.badgeTitle;
    
    if ([[TSCBadgeController sharedController] hasEarntBadgeWithId:badge.badgeId]) {
        [cell setCompleted:YES];
    } else {
        [cell setCompleted:NO];
    }
    
    [cell layoutSubviews];
    
    return cell;
}

#pragma markk Collection view layout delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.badges.count == 1) {
        return CGSizeMake(self.bounds.size.width, self.bounds.size.height + 10);
    }
    
    return CGSizeMake(self.bounds.size.width/floor(self.bounds.size.width/120), self.bounds.size.height + 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self handleSelectedQuizAtIndexPath:indexPath];
}

#pragma mark - Action handling

- (void)handleSelectedQuizAtIndexPath:(NSIndexPath *)indexPath
{
    TSCBadge *badge = self.badges[indexPath.item];
    
    if([[TSCBadgeController sharedController] hasEarntBadgeWithId:badge.badgeId]) {
        
        NSString *defaultShareBadgeMessage = [NSString stringWithLocalisationKey:@"_TEST_COMPLETED_SHARE"];
        UIActivityViewController *shareViewController = [[UIActivityViewController alloc] initWithActivityItems:@[[TSCImage imageWithJSONObject:badge.badgeIcon], badge.badgeShareMessage ?: defaultShareBadgeMessage] applicationActivities:nil];
        shareViewController.excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll, UIActivityTypePrint, UIActivityTypeAssignToContact];
        
        if ([shareViewController respondsToSelector:@selector(popoverPresentationController)]) {
            UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
            shareViewController.popoverPresentationController.sourceView = keyWindow;
            shareViewController.popoverPresentationController.sourceRect = CGRectMake(keyWindow.center.x, CGRectGetMaxY(keyWindow.frame), 100, 100);
            shareViewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCStatEventNotification" object:self userInfo:@{@"type":@"event", @"category":@"Badge", @"action":[NSString stringWithFormat:@"Shared %@ badge", badge.badgeTitle]}];
        
        if (TSC_isPad() && ![TSCThemeManager isOS8]) {
            [[TSCSplitViewController sharedController] presentFullScreenViewController:shareViewController animated:YES];
        } else {
            [self.parentViewController presentViewController:shareViewController animated:YES completion:nil];
        }
        
    } else {
        
        for (TSCQuizPage *quizPage in self.quizzes) {
            
            if ([quizPage.quizBadge.badgeId isEqualToString:badge.badgeId]) {
                
                [quizPage resetInitialPage];
                
                if (TSC_isPad()) {
                    
                    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:quizPage];
                    navController.modalPresentationStyle = UIModalPresentationFormSheet;
                    
                    UIViewController *visibleViewController = [[[UIApplication sharedApplication] keyWindow] visibleViewController];
                    
                    if (visibleViewController.navigationController && visibleViewController.presentingViewController) {
                        
                        UINavigationController *navController = visibleViewController.navigationController;
                        [navController pushViewController:quizPage animated:true];
                        
                    } else if ([[[[UIApplication sharedApplication] keyWindow] rootViewController] isKindOfClass:[TSCSplitViewController class]]) {
                        
                        [[TSCSplitViewController sharedController] setRightViewController:quizPage fromNavigationController:self.parentViewController.navigationController];
                        
                    } else {
                        
                        [self.parentViewController.navigationController presentViewController:navController animated:YES completion:nil];
                        
                    }

                } else {
                    
                    quizPage.hidesBottomBarWhenPushed = YES;
                    [self.parentViewController.navigationController pushViewController:quizPage animated:YES];
                    
                }
                break;
            }
        }
        
    }
}

#pragma mark - Refreshing

- (void)setBadges:(NSArray *)badges
{
    _badges = badges;
    [self reload];
}

@end
