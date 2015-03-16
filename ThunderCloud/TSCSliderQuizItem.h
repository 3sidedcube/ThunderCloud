//
//  TSCImageSliderSelectionQuestion.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 14/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@import UIKit;

@class TSCQuizItem;

@interface TSCSliderQuizItem : UIViewController

@property (nonatomic, strong) TSCQuizItem *question;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *unitsLabel;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *hintLabel;

- (instancetype)initWithQuestion:(TSCQuizItem *)question;

@end
