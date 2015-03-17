//
//  TSCAreaSelectionQuestion.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 14/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//
#import <UIKit/UIKit.h>

@class TSCQuizItem;

/**
 A table view which presents the user with a question and hint with an image below which the user has to select a correct region on to get the question correct.
 
 A good use for this would be for testing users on geographical locations on a map
 */
@interface TSCAreaQuizItem : UIViewController
{
    /**
     The circle which is displayed around the point a user has selected
     */
    CAShapeLayer *circle;
}

/**
 Initializes a new object with a given `TSCQuizItem`
 @param question The question to be displayed to the user
 */
- (instancetype)initWithQuestion:(TSCQuizItem *)question;

/**
 @abstract The question currently being displayed to the user
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
 @abstract The image view which the user can tap on to select an area
 */
@property (nonatomic, strong) UIImageView *imageView;

/**
 @abstract The image which the user has to select an area on to answer the question
 */
@property (nonatomic, strong) UIImage *image;

@end
