//
//  TSCAnimationTableViewCell.h
//  ThunderCloud
//
//  Created by Matthew Cheetham on 20/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

@import ThunderTable;
@class TSCAnimation;

/**
 `TSCAnimationTableViewCell` is a cell that loops through a number of `TSCAnimationFrame`s to create an animation.
 */
@interface TSCAnimationTableViewCell : TSCTableImageViewCell

/**
 @abstract The animation to display
 */
@property (nonatomic, strong) TSCAnimation *animation;

/**
 @abstract Gives you back the index of the image that is currently being displayed in the animation
 */
@property (nonatomic) int currentIndex;

/**
 Restarts the cells animations
 */
- (void)resetAnimations;

@end
