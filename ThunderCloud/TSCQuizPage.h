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
@property (nonatomic, strong) NSString *winMessage;
@property (nonatomic, strong) NSString *loseMessage;
@property (nonatomic, strong) NSString *shareMessage;
@property (nonatomic, strong) NSString *quizId;
@property (nonatomic, strong) TSCBadge *quizBadge;
@property (nonatomic, strong) NSString *quizTitle;
@property (nonatomic, strong) UIViewController *initialQuizQuestion;
@property (nonatomic, strong) NSMutableArray *loseRelatedLinks;
@property (nonatomic, strong) NSMutableArray *winRelatedLinks;

- (id)initWithDictionary:(NSDictionary *)dictionary;

- (void)resetInitialPage;

@end