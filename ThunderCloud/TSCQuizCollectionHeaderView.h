//
//  TSCQuizCollectionHeaderView.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 14/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@class TSCQuizItem;

#import <UIKit/UIKit.h>

/**
 A view used to present the question and hint to the user at the top of a collection view
 */
@interface TSCQuizCollectionHeaderView : UICollectionReusableView

/**
 @abstract Used to display the question to the user
 */
@property (nonatomic, strong) UILabel *questionLabel;

/**
 @abstract Used to display a hint to the user
 */
@property (nonatomic, strong) UILabel *hintLabel;

/**
 @abstract The question to display in the header
 */
@property (nonatomic, strong) TSCQuizItem *question;

@end
