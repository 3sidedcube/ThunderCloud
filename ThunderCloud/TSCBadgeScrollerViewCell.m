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

@implementation TSCBadgeScrollerViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        UIImage *backgroundImage = [[UIImage imageNamed:@"RCPortalViewCell-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
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
        
        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 16)];
        self.pageControl.currentPage = 0;
        self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        self.pageControl.currentPageIndicatorTintColor = [[TSCThemeManager sharedTheme] mainColor];
        self.pageControl.currentPage = 0;
        self.pageControl.userInteractionEnabled = NO;
        [self addSubview:self.pageControl];
        
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
    self.pageControl.frame = CGRectMake(0, self.frame.size.height - 20, self.frame.size.width, 12);
    
    if (![TSCThemeManager isOS7]) {
        self.collectionView.frame = CGRectMake(self.collectionView.frame.origin.x - 10,
                                               self.collectionView.frame.origin.y,
                                               self.collectionView.frame.size.width,
                                               self.collectionView.frame.size.height);
    }
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
    
    if ([[TSCBadgeController sharedController] hasEarntBadgeWithId:badge.badgeId]) {
        cell.badgeImage.alpha = 1.0;
    } else {
        cell.badgeImage.alpha = 0.5;
    }
    
    return cell;
}

#pragma markk Collection view layout delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.bounds.size.height, self.bounds.size.height);
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
    TSCBadge *badge = self.badges[indexPath.item];
    
    if ([[TSCBadgeController sharedController] hasEarntBadgeWithId:badge.badgeId]) {
        TSCBadgeShareViewController *shareView = [[TSCBadgeShareViewController alloc] initWithBadge:badge];
        
        if (isPad()) {
           // [[TSCSplitViewController sharedController] setRightViewController:shareView fromNavigationController:self.parentViewController];
        } else {
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:shareView];
            [self.parentViewController.navigationController presentViewController:navController animated:YES completion:nil];
        }
    }
}

#pragma mark - Refreshing

- (void)setBadges:(NSArray *)badges
{
    _badges = badges;
    [self.collectionView reloadData];
    self.pageControl.numberOfPages = ceil(self.badges.count / 2);

}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float page = scrollView.contentOffset.x / scrollView.frame.size.width;
    
    self.currentPage = (int)page;
}

#pragma mark - Setter methods

- (void)setCurrentPage:(int)currentPage
{
    _currentPage = currentPage;
    
    self.pageControl.currentPage = currentPage;
    
    //[self setupContentOffset];
}

@end
