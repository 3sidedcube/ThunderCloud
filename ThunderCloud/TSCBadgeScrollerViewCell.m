//
//  TSCBadgeScrollerViewCell.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 27/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCBadgeScrollerViewCell.h"
#import "TSCBadgeScrollerItemViewCell.h"
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

@implementation TSCBadgeScrollerViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImage *backgroundImage = [[UIImage imageNamed:@"TSCPortalViewCell-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        self.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        [self.contentView addSubview:self.backgroundView];
        
        self.collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        self.collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.collectionViewLayout];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.backgroundColor = [UIColor clearColor];
        self.collectionView.alwaysBounceHorizontal = YES;
        self.collectionView.pagingEnabled = YES;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        [self.contentView addSubview:self.collectionView];
        
        [self.collectionView registerClass:[TSCBadgeScrollerItemViewCell class] forCellWithReuseIdentifier:@"Cell"];
        
        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, 140, 16)];
        self.pageControl.currentPage = 0;
        self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        self.pageControl.currentPageIndicatorTintColor = [[TSCThemeManager sharedTheme] mainColor];
        self.pageControl.userInteractionEnabled = NO;
        [self.contentView addSubview:self.pageControl];
        
        [[NSNotificationCenter defaultCenter] addObserver:self.collectionView selector:@selector(reloadData) name:QUIZ_COMPLETED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self.collectionView selector:@selector(reloadData) name:BADGES_CLEARED_NOTIFICATION object:nil];
        
        self.currentPage = 0;
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
    self.pageControl.numberOfPages = ceil((double)self.badges.count/2);
    
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
    
    TSCBadgeScrollerItemViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.badgeImage.image = [TSCImage imageWithDictionary:badge.badgeIcon];
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
    return CGSizeMake(self.collectionView.frame.size.width/2, self.bounds.size.height + 10);
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
        UIActivityViewController *shareViewController = [[UIActivityViewController alloc] initWithActivityItems:@[[TSCImage imageWithDictionary:badge.badgeIcon], badge.badgeShareMessage ?: defaultShareBadgeMessage] applicationActivities:nil];
        shareViewController.excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll, UIActivityTypePrint, UIActivityTypeAssignToContact];
        
        if ([shareViewController respondsToSelector:@selector(popoverPresentationController)]) {
            UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
            shareViewController.popoverPresentationController.sourceView = keyWindow;
            shareViewController.popoverPresentationController.sourceRect = CGRectMake(keyWindow.center.x, CGRectGetMaxY(keyWindow.frame), 100, 100);
            shareViewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCStatEventNotification" object:self userInfo:@{@"type":@"event", @"category":@"Badge", @"action":[NSString stringWithFormat:@"Shared %@ badge", badge.badgeTitle]}];
        
        if (isPad() && ![TSCThemeManager isOS8]) {
            [[TSCSplitViewController sharedController] presentFullScreenViewController:shareViewController animated:YES];
        } else {
            [self.parentViewController presentViewController:shareViewController animated:YES completion:nil];
        }
        
    } else {
        
        for (TSCQuizPage *quizPage in self.quizzes) {
            
            if ([quizPage.quizBadge.badgeId isEqualToString:badge.badgeId]) {
                
                [quizPage resetInitialPage];
                if (isPad()) {
                    
                    [[TSCSplitViewController sharedController] setRightViewController:quizPage fromNavigationController:self.parentViewController.navigationController];
                    
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
    [self.collectionView reloadData];
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float page = scrollView.contentOffset.x / scrollView.frame.size.width;
    self.currentPage = ceil(page);
}

#pragma mark - Setter methods

- (void)setCurrentPage:(int)currentPage
{
    _currentPage = currentPage;
    self.pageControl.currentPage = currentPage;
}

@end
