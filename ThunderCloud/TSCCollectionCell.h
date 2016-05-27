//
//  TSCCollectionCell.h
//  ThunderCloud
//
//  Created by Simon Mitchell on 26/05/2016.
//  Copyright © 2016 threesidedcube. All rights reserved.
//

#import <ThunderTable/ThunderTable.h>

/**
 A subclass of `TSCTableViewCell` which displays the user a collection view.
 */
@interface TSCCollectionCell : TSCTableViewCell <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

/**
 @abstract The collection view used to display the list of items
 */
@property (nonatomic, strong) UICollectionView *collectionView;

/**
 @abstract The `UICollectionViewFlowLayout` of the cells collection view
 */
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;

/**
 @abstract The containing navigation controller of the cell
 */
@property (nonatomic, strong) UINavigationController *parentNavigationController;

/**
 @abstract A paging control showing how many pages of apps the user can scroll through
 */
@property (nonatomic, strong) UIPageControl *pageControl;

@end
