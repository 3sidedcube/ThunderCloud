//
//  TSCBadgeScrollerViewCell.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 27/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@import UIKit;
@import ThunderTable;

/**
 `TSCBadgeScrollerViewCell` is a `TSCTableViewCell` with a `UICollectionView` inside of it. It is used to display all of the badges in a single cell.
 */
@interface TSCBadgeScrollerViewCell : TSCTableViewCell <UICollectionViewDataSource, UICollectionViewDelegate>

/**
 @abstract a `UICollectionView` that contains an array of `TSCBadgeScrollerItemViewCell`s
 */
@property (nonatomic, strong) UICollectionView *collectionView;

/**
 @abstract a `UICollectionViewFlowLayout` that layouts out the collection view
 */
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;

/**
 @abstract An array of `TSCBadge`s to be displayed in the collection view
 */
@property (nonatomic, strong) NSArray *badges;

/**
 @abstract A `UINavigationController` that represents the navigation controller the cell is contained in
 @discussion This is used to push a `TSCQuizPage` when a badge is clicked
 */
@property (nonatomic, strong) UINavigationController *parentNavigationController;

/**
 @abstract A `UIPageControl` that shows how many pages there are to scroll in the collection view
 @discussion Each page controller represents 2 badges
 */
@property (nonatomic, strong) UIPageControl *pageControl;

/**
 @abstract An int that represents the current page
 */
@property (nonatomic) int currentPage;

/**
 @abstract An array of `TSCQuizPage`s
 @discussion These quiz badges are pushed onto screen when a badge is selected
 */
@property (nonatomic, strong) NSMutableArray *quizzes;

/**
 This is called when a badge is clicked, it gets the relevant quiz for the badge and pushes a `TSCQuizPage` on to the screen. If a badge has been completed it pushes the quizzes completion page
 @param indexPath A `NSIndexPath` of the selected collection view cell
 */
- (void)handleSelectedQuizAtIndexPath:(NSIndexPath *)indexPath;

@end
