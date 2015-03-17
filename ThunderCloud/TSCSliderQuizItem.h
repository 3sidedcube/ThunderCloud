//
//  TSCImageSliderSelectionQuestion.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 14/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@import UIKit;

@class TSCQuizItem;

/**
 A view controller which presents the user with a question, hint a contextual image and a slider to select a correct value for the answer to the question
 */
@interface TSCSliderQuizItem : UIViewController

/**
 Initializes a new object with a given `TSCQuizItem`
 @param question The question to be displayed to the user
 */
- (instancetype)initWithQuestion:(TSCQuizItem *)question;

/**
 @abstract The quiz item being displayed in the `TSCTableViewController`
 */
@property (nonatomic, strong) TSCQuizItem *question;

/**
 @abstract The label which displays the question to the user
 */
@property (nonatomic, strong) UILabel *titleLabel;

/**
 @abstract The label which displays a hint to the user on how to answer the question
 */
@property (nonatomic, strong) UILabel *hintLabel;

/**
 @abstract The image view which displays a contextual image to the question
 */
@property (nonatomic, strong) UIImageView *imageView;

/**
 @abstract A label which displays the units of the slider (and answer)
 */
@property (nonatomic, strong) UILabel *unitsLabel;

/**
 @abstract The slider which is displayed to the user for them to select an answer using
 */
@property (nonatomic, strong) UISlider *slider;

@end
