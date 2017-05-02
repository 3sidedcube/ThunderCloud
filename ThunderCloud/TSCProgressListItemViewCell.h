//
//  TSCProgressListItemViewCell.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 27/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCEmbeddedLinksListItemCell.h"

/**
 A table view cell which displays a title and a users progress through a set of quizzes (Or anything else for that matter)
 */
@interface TSCProgressListItemViewCell : TSCEmbeddedLinksListItemCell

/**
 @abstract A label which displays a string indicating to the user what will happen if they click on the cell
 */
@property (nonatomic, strong) UILabel *nextLabel;

/**
 @abstract A label displaying the title of the quiz
 */
@property (nonatomic, strong) UILabel *testNameLabel;

/**
 @abstract A label displaying the users progress through a set of quizzes
 */
@property (nonatomic, strong) UILabel *quizCountLabel;
    
/**
 The amount of padding to add either side of the text in the label
 */
@property (nonatomic) double quizLabelHorizontalPadding;
    
/**
 The amount of padding to add above and below the text in the label
 */
@property (nonatomic) double quizLabelVerticalPadding;
    
/**
 The corner radius to set on the quiz label. In case you want it different
 */
@property (nonatomic) CGFloat quizLabelCornerRadius;

@end
