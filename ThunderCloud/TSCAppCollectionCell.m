//
//  TSCAppCollectionCell.m
//  ThunderCloud
//
//  Created by Matt Cheetham on 23/06/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import "TSCAppCollectionCell.h"
#import "TSCAppScrollerItemViewCell.h"
#import "TSCAppCollectionItem.h"
#import <StoreKit/StoreKit.h>
#import "TSCAppIdentity.h"
#import "TSCStormObject.h"
#import "NSString+LocalisedString.h"
@import ThunderTable;
@import ThunderBasics;

@interface TSCAppCollectionCell ()  <UICollectionViewDelegate, UICollectionViewDataSource, SKStoreProductViewControllerDelegate>

@property (nonatomic) NSInteger currentPage;

@end

@implementation TSCAppCollectionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImage *backgroundImage = [[UIImage imageNamed:@"TSCPortalViewCell-bg" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        
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
        
        Class cellClass = [TSCStormObject classForClassKey:NSStringFromClass([TSCAppScrollerItemViewCell class])];
        [self.collectionView registerClass:[cellClass isSubclassOfClass:[UICollectionViewCell class]] ? cellClass : [TSCAppScrollerItemViewCell class] forCellWithReuseIdentifier:@"Cell"];
        
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
    self.pageControl.numberOfPages = ceil(self.collectionView.contentSize.width / self.collectionView.frame.size.width);
}

#pragma mark Collection view datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.apps.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TSCAppScrollerItemViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    TSCAppCollectionItem *item = self.apps[indexPath.item];
    
    if ([cell respondsToSelector:@selector(setAppIconView:)]) {
        cell.appIconView.image = item.appIcon;
    }
    
    if ([cell respondsToSelector:@selector(setNameLabel:)]) {
        cell.nameLabel.text = item.appName;
    }
    
    if ([cell respondsToSelector:@selector(setPriceLabel:)]) {
        cell.priceLabel.text = item.appPrice;
    }
    
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
    TSCAppCollectionItem *item = self.apps[indexPath.item];
    TSCAppIdentity *identity = item.appIdentity;
    NSURL *launchURL = [NSURL URLWithString:identity.launcher];
    
    if ([[UIApplication sharedApplication] canOpenURL:launchURL]) {
        
        TSCAlertViewController *alertView = [TSCAlertViewController alertControllerWithTitle:[NSString stringWithLocalisationKey:@"_COLLECTION_APP_CONFIRMATION_TITLE" fallbackString:@"Switching Apps"] message:[NSString stringWithLocalisationKey:@"_COLLECTION_APP_CONFIRMATION_MESSAGE" fallbackString:@"You will now be taken to the app you have selected"] preferredStyle:TSCAlertViewControllerStyleAlert];
        [alertView addAction:[TSCAlertAction actionWithTitle:[NSString stringWithLocalisationKey:@"_COLLECTION_APP_CONFIRMATION_OKAY" fallbackString:@"Okay"] style:TSCAlertActionStyleDefault handler:^(TSCAlertAction *action) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCStatEventNotification" object:self userInfo:@{@"type":@"event", @"category":@"Collect them all", @"action":@"Open"}];
            
            [[UIApplication sharedApplication] openURL:launchURL];
            
        }]];
        
        [alertView addAction:[TSCAlertAction actionWithTitle:[NSString stringWithLocalisationKey:@"_COLLECTION_APP_CONFIRMATION_CANCEL" fallbackString:@"Cancel"] style:TSCAlertActionStyleCancel handler:nil]];
        
        [alertView showInView:self.parentViewController.view];
        
        
    } else {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCStatEventNotification" object:self userInfo:@{@"type":@"event", @"category":@"Collect them all", @"action":@"App Store"}];
        
        [[UINavigationBar appearance] setTintColor:[[TSCThemeManager sharedTheme] titleTextColor]];
        
        SKStoreProductViewController *viewController = [[SKStoreProductViewController alloc] init];
        [viewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier : identity.iTunesId} completionBlock:^(BOOL result, NSError *error) {
        }];
        viewController.delegate = self;
        [self.parentViewController.navigationController presentViewController:viewController animated:YES completion:nil];
        
    }
}

#pragma mark - Refreshing

- (void)setApps:(NSArray *)apps
{
    _apps = apps;
    [self.collectionView reloadData];
    self.pageControl.numberOfPages = ceil(self.collectionView.contentSize.width / self.collectionView.frame.size.width);
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float page = scrollView.contentOffset.x / scrollView.frame.size.width;
    self.currentPage = ceil(page);
}

#pragma mark - Setter methods

- (void)setCurrentPage:(NSInteger)currentPage
{
    _currentPage = currentPage;
    self.pageControl.currentPage = currentPage;
}

#pragma mark SKProductViewControllerDelegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
