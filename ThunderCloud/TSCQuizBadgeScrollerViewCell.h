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
@interface TSCQuizBadgeScrollerViewCell : TSCCollectionCell

/**
 @abstract An array of `TSCBadge`s to be displayed in the collection view
 */
@property (nonatomic, strong) NSArray *badges;

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
