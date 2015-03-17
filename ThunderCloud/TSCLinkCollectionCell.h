//
//  TSCLinkCollectionCell.h
//  ThunderCloud
//
//  Created by Simon Mitchell on 28/10/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

@import UIKit;
@import ThunderTable;

/**
 A subclass of `TSCTableViewCell` which displays the user a collection view containing a list of links.
 Links in this collection view are displayed as their image
 */
@interface TSCLinkCollectionCell : TSCTableViewCell

/**
 @abstract The collection view which displays the links
 */
@property (nonatomic, strong) UICollectionView *collectionView;

/**
 @abstract The `UICollectionViewFlowLayout` of the cells collection view
 */
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;

/**
 @abstract The array of `TSCLink`s to display in the cell
 */
@property (nonatomic, strong) NSArray *links;

/**
 @abstract The containing navigation controller of the cell
 */
@property (nonatomic, strong) UINavigationController *parentNavigationController;

/**
 @abstract A paging control showing how many pages of apps the user can scroll through
 */
@property (nonatomic, strong) UIPageControl *pageControl;

@end
