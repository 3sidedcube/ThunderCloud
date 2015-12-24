//
//  TSCAppCollectionCell.h
//  ThunderCloud
//
//  Created by Matt Cheetham on 23/06/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

@import UIKit;
@import ThunderTable;

/**
 A subclass of `TSCTableViewCell` which displays the user a collection view containing a list of apps.
 Apps in this collection view are displayed as their app icon, with a price and name below them
 */
@interface TSCAppCollectionCell : TSCTableViewCell <UICollectionViewDataSource, UICollectionViewDelegate>

/**
 @abstract The collection view used to display the list of apps
 */
@property (nonatomic, strong) UICollectionView *collectionView;

/**
 @abstract The `UICollectionViewFlowLayout` of the cells collection view
 */
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;

/**
 @abstract The array of apps to be shown within the collection view
 */
@property (nonatomic, strong) NSArray *apps;

/**
 @abstract The containing navigation controller of the cell
 */
@property (nonatomic, strong) UINavigationController *parentNavigationController;

/**
 @abstract A paging control showing how many pages of apps the user can scroll through
 */
@property (nonatomic, strong) UIPageControl *pageControl;

@end
