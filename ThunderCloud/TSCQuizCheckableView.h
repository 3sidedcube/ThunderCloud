//
//  TSCQuizCheckableView.h
//  ThunderCloud
//
//  Created by Sam Houghton on 16/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

#import <UIKit/UIKit.h>
@import ThunderTable;

@interface TSCQuizCheckableView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) TSCCheckView *checkView;
@property (nonatomic, strong) NSIndexPath *indexPath;

@end
