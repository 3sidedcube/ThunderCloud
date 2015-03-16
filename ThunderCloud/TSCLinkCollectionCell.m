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

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
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
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.collectionView.frame = self.bounds;
    self.pageControl.numberOfPages = ceil(self.collectionView.contentSize.width / self.collectionView.frame.size.width);
    
    if (![TSCThemeManager isOS7]) {
        self.collectionView.frame = CGRectMake(self.collectionView.frame.origin.x - 10, self.collectionView.frame.origin.y, self.collectionView.frame.size.width, self.collectionView.frame.size.height);
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
}

@end
