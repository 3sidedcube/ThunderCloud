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

@interface TSCAppCollectionCell ()  <SKStoreProductViewControllerDelegate>

@end

@implementation TSCAppCollectionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        Class cellClass = [TSCStormObject classForClassKey:NSStringFromClass([TSCAppScrollerItemViewCell class])];
        [self.collectionView registerClass:[cellClass isSubclassOfClass:[UICollectionViewCell class]] ? cellClass : [TSCAppScrollerItemViewCell class] forCellWithReuseIdentifier:@"Cell"];
        
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.collectionView.frame = CGRectMake(0, 1, self.contentView.frame.size.width, 120);
    self.pageControl.frame = CGRectMake(0, self.frame.size.height - 17, self.frame.size.width, 12);
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
    return CGSizeMake(80, 120);
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
    [self reload];
}

#pragma mark SKProductViewControllerDelegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
