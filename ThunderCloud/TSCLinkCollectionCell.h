//
//  TSCLinkCollectionCell.h
//  ThunderCloud
//
//  Created by Simon Mitchell on 28/10/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

@import UIKit;
@import ThunderTable;

@interface TSCLinkCollectionCell : TSCTableViewCell

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;
@property (nonatomic, strong) NSArray *links;
@property (nonatomic, strong) UINavigationController *parentNavigationController;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic) int currentPage;

@end
