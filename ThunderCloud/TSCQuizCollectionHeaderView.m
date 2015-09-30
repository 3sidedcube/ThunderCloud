//
//  TSCQuizCollectionHeaderView.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 14/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCQuizCollectionHeaderView.h"
#import "TSCQuizItem.h"
@import ThunderBasics;

@interface TSCQuizCollectionHeaderView ()

@property (nonatomic, strong) UIView *seperator;

@end

@implementation TSCQuizCollectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        //Question Label
        self.questionLabel = [[UILabel alloc] init];
        self.questionLabel.backgroundColor = [UIColor whiteColor];
        self.questionLabel.text = self.question.questionText;
        self.questionLabel.numberOfLines = 0;
        self.questionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.questionLabel.textAlignment = NSTextAlignmentCenter;
        self.questionLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        self.questionLabel.textColor = [UIColor blackColor];
        
        //Hint Label
        self.hintLabel = [[UILabel alloc] init];
        self.hintLabel.backgroundColor = [UIColor whiteColor];
        self.hintLabel.text = self.question.hintText;
        self.hintLabel.numberOfLines = 0;
        self.hintLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.hintLabel.font = [UIFont systemFontOfSize:16];
        self.hintLabel.textColor = [UIColor lightGrayColor];
        self.hintLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:self.questionLabel];
        [self addSubview:self.hintLabel];
        
        self.seperator = [[UIView alloc] init];
        self.seperator.backgroundColor = [[TSCThemeManager sharedTheme] backgroundColor];
        
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.seperator];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize constraintForHeaderWidth = CGSizeMake(self.bounds.size.width - 20, MAXFLOAT);
    
    // Calculated question size
    CGSize questionSize = [self.questionLabel sizeThatFits:constraintForHeaderWidth];
    CGSize hintSize = [self.hintLabel sizeThatFits:constraintForHeaderWidth];
    
    self.questionLabel.frame = CGRectMake(10, 10, constraintForHeaderWidth.width, questionSize.height);
    self.hintLabel.frame = CGRectMake(10, self.questionLabel.frame.size.height + 20, constraintForHeaderWidth.width, hintSize.height);
    
    if (!TSC_isPad()) {
        [self centerSubviewsVerticallyWithOffset:34];
    }
    
    self.seperator.frame = CGRectMake(0, self.frame.size.height - 15, self.frame.size.width, 15);
}

- (void)setQuestion:(TSCQuizItem *)question
{
    _question = question;
    self.questionLabel.text = self.question.questionText;
    self.hintLabel.text = self.question.hintText;
}

@end
