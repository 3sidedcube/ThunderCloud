//
//  TSCBadgeScrollerViewCell.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 27/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@import UIKit;
@import ThunderTable;

@interface TSCBadgeScrollerViewCell : TSCTableViewCell <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;
@property (nonatomic, strong) NSArray *badges;
@property (nonatomic, strong) UINavigationController *parentNavigationController;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic) int currentPage;
@property (nonatomic, strong) NSMutableArray *quizzes;

@end
