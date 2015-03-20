//
//  TSCQuizCollectionViewCell.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 14/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSCStandardGridItem.h"

/**
 A collection view cell used to display an image in a `TSCImageQuizItem` question type to the user
 
 This cell adds a gradient to the bottom of the cell to avoid white text being displayed on a white background
 */
@interface TSCQuizCollectionViewCell : TSCStandardGridItem

/**
 @abstract The gradient displayed at the bottom of the cell used to avoid un-readable text
 */
@property (nonatomic, strong) UIImageView *gradientImageView;

@end
