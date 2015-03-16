//
//  TSCQuizQuestionViewController.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 11/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@class TSCQuizItem;
@import UIKit;

@interface TSCQuizQuestionViewController : UIViewController

@property (nonatomic, strong) TSCQuizItem *question;

- (instancetype)initWithQuizQuestion:(TSCQuizItem *)question;

@end
