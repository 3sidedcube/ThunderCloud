//
//  TSCQuizQuestionViewController.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 11/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@class TSCQuizQuestion;
@import UIKit;

@interface TSCQuizQuestionViewController : UIViewController

@property (nonatomic, strong) TSCQuizQuestion *question;

- (id)initWithQuizQuestion:(TSCQuizQuestion *)question;


@end
