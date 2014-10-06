//
//  TSCAppCollectionCell.h
//  ThunderCloud
//
//  Created by Matt Cheetham on 23/06/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

@import UIKit;
@import ThunderTable;

@interface TSCAppCollectionCell : TSCTableViewCell

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;
@property (nonatomic, strong) NSArray *apps;
@property (nonatomic, strong) UINavigationController *parentNavigationController;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic) int currentPage;

@end
