//
//  TSCQuizQuestionViewController.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 11/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCQuizQuestionViewController.h"
#import "TSCQuizItem.h"

@interface TSCQuizQuestionViewController ()

@end

@implementation TSCQuizQuestionViewController

- (id)initWithQuizQuestion:(TSCQuizItem *)question
{
    if (self = [super init]) {
        self.question = question;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

@end
