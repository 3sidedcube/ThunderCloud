//
//  TSCLinkCollectionCell.m
//  ThunderCloud
//
//  Created by Simon Mitchell on 28/10/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

#import "TSCLinkCollectionCell.h"
#import "TSCLinkScrollerItemViewCell.h"
#import "TSCLinkCollectionItem.h"
#import "UINavigationController+TSCNavigationController.h"

@interface TSCLinkCollectionCell ()  <UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation TSCLinkCollectionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        UIImage *backgroundImage = [[UIImage imageNamed:@"RCPortalViewCell-bg" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
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
        
        [self.collectionView registerClass:[TSCLinkScrollerItemViewCell class] forCellWithReuseIdentifier:@"Cell"];
        
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
    return self.links.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TSCLinkScrollerItemViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    TSCLinkCollectionItem *item = self.links[indexPath.item];
    
    cell.imageView.image = item.image;
    
    return cell;
}

#pragma markk Collection view layout delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(80, self.bounds.size.height);
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
    
    TSCLinkCollectionItem *item = self.links[indexPath.item];
    TSCLink *link = item.link;
    [self.parentViewController.navigationController pushLink:link];
}

#pragma mark - Refreshing

- (void)setLinks:(NSArray *)links
{
    _links = links;
    [self.collectionView reloadData];
    self.pageControl.numberOfPages = ceil(self.links.count / 2);
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
