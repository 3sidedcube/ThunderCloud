//
//  TSCAreaSelectionQuestion.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 14/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//
#import <UIKit/UIKit.h>

@class TSCQuizItem;

@interface TSCAreaQuizItem : UIViewController
{
    CAShapeLayer *circle;
}

@property (nonatomic, strong) TSCQuizItem *question;
@property (nonatomic, strong) UIImageView *tappableImageView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

- (id)initWithQuestion:(TSCQuizItem *)question;

@end
