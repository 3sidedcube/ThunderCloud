//
//  TSCQuizGridCell.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 20/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSCStandardGridItem.h"

/**
  Used to display a quiz badge in a collection view
 */
@interface TSCQuizGridCell : TSCStandardGridItem

/**
 @abstract The image to display if the quiz has been completed
 */
@property (nonatomic, strong) UIImage *completedImage;

/**
 @abstract The image to display if the quiz hasn't been completed
 */
@property (nonatomic, strong) UIImage *nonCompletedImage;

/**
 @abstract Whether or not the quiz has been completed
 */
@property (nonatomic) BOOL isCompleted;

/**
 @abstract Causes the badge displayed to wiggle... wiggle wiggle.
 */
- (void)wiggle;

/**
 @abstract Animates in the imageView for the cell
 */
- (void)makeImageViewVisible;

@end