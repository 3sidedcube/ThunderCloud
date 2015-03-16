//
//  TSCQuizPage.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 11/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@import UIKit;

@class TSCBadge;

@interface TSCQuizPage : UIViewController

@property (nonatomic, strong) NSMutableArray *questions;
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, copy) NSString *winMessage;
@property (nonatomic, copy) NSString *loseMessage;
@property (nonatomic, copy) NSString *shareMessage;
@property (nonatomic, copy) NSString *quizId;
@property (nonatomic, strong) TSCBadge *quizBadge;
@property (nonatomic, copy) NSString *quizTitle;
@property (nonatomic, strong) UIViewController *initialQuizQuestion;
@property (nonatomic, strong) NSMutableArray *loseRelatedLinks;
@property (nonatomic, strong) NSMutableArray *winRelatedLinks;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (void)resetInitialPage;

@end