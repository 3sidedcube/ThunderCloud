//
//  TSCQuizCollectionHeaderView.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 14/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@class TSCQuizQuestion;

#import <UIKit/UIKit.h>

@interface TSCQuizCollectionHeaderView : UICollectionReusableView

@property (nonatomic, strong) UILabel *questionLabel;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UIView *seperator;

@property (nonatomic, strong) TSCQuizQuestion *question;

@end
