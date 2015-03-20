//
//  TSCAnimatedTableImageViewCell.h
//  ThunderStorm
//
//  Created by Andrew Hart on 04/12/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@import ThunderTable;

/**
 `TSCAnimatedTableImageViewCell` is a cell that loops through a number of images.
 @note This class is deprecated. Please use `TSCAnimationTableViewCell`
 */
@interface TSCAnimatedTableImageViewCell : TSCTableImageViewCell

/**
 @abstract An array of `UIImage`s for the cell to animate through
 */
@property (nonatomic, strong) NSMutableArray *images;

/**
 @abstract An array of time intervals to determine how long each image is displayed for
 */
@property (nonatomic, strong) NSMutableArray *delays;

/**
 @abstract Gives you back the index of the image that is currently being displayed
 */
@property (nonatomic) int currentIndex;

/**
 Restarts the cells animations
 */
- (void)resetAnimations;

@end
