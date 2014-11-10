//
//  TSCQuizCollectionHeaderView.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 14/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCQuizCollectionHeaderView.h"
#import "TSCQuizItem.h"

@implementation TSCQuizCollectionHeaderView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        //Question Label
        self.questionLabel = [[UILabel alloc] init];
        self.questionLabel.backgroundColor = [UIColor clearColor];
        self.questionLabel.text = self.question.questionText;
        self.questionLabel.numberOfLines = 0;
        self.questionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.questionLabel.textAlignment = NSTextAlignmentCenter;
        self.questionLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        self.questionLabel.textColor = [UIColor blackColor];
        
        //Hint Label
        self.hintLabel = [[UILabel alloc] init];
        self.hintLabel.backgroundColor = [UIColor clearColor];
        self.hintLabel.text = self.question.hintText;
        self.hintLabel.numberOfLines = 0;
        self.hintLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.hintLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        self.hintLabel.textColor = [UIColor blackColor];
        self.hintLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:self.questionLabel];
        [self addSubview:self.hintLabel];
        
        self.seperator = [[UIView alloc] init];
        self.seperator.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1.0];
        
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
    self.hintLabel.frame = CGRectMake(10, self.questionLabel.frame.size.height + 15, constraintForHeaderWidth.width, hintSize.height);
    
    self.seperator.frame = CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1);
}

- (void)setQuestion:(TSCQuizItem *)question
{
    _question = question;
    self.questionLabel.text = self.question.questionText;
    self.hintLabel.text = self.question.hintText;
}

@end
