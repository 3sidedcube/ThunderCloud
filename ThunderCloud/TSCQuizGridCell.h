//
//  TSCQuizGridCell.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 20/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSCStandardGridCell.h"

@interface TSCQuizGridCell : TSCStandardGridCell

@property (nonatomic, strong) UIImage *completedImage;
@property (nonatomic, strong) UIImage *nonCompletedImage;
@property (nonatomic) BOOL isCompleted;
@property (nonatomic) BOOL isAniamtedIn;

- (void)wiggle;
- (void)makeImageViewVisible;

@end