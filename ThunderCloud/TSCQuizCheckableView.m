//
//  TSCQuizCheckableView.m
//  ThunderCloud
//
//  Created by Sam Houghton on 16/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

#import "TSCQuizCheckableView.h"
#import "ThunderCloud/ThunderCloud-Swift.h"
@import ThunderBasics;

@implementation TSCQuizCheckableView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.checkView = [[TSCCheckView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [self addSubview:self.checkView];
        
        self.titleLabel = [UILabel new];
        self.titleLabel.font = [UIFont systemFontOfSize:17];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:self.titleLabel];
        
        self.backgroundColor = [UIColor whiteColor];
        
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.checkView.frame = CGRectMake(10, self.bounds.size.height / 2 - 15, 30, 30);
    CGSize constrainedSize = CGSizeMake(self.bounds.size.width - CGRectGetMaxX(self.checkView.frame) - 20, MAXFLOAT);
    CGSize titleSize = [self.titleLabel sizeThatFits:constrainedSize];
    self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.checkView.frame) + 10, 0, constrainedSize.width, titleSize.height);
    [self.titleLabel setCenterY:self.frame.size.height/2];
    
    CALayer *upperBorder = [CALayer layer];
    upperBorder.backgroundColor = [UIColor colorWithWhite:0.85 alpha:0.4].CGColor;
    upperBorder.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 1.0f);
    [self.layer addSublayer:upperBorder];
    
    if ([[TSCStormLanguageController sharedController] isRightToLeft] && [self isMemberOfClass:[TSCQuizCheckableView class]]) {
        
        for (UIView *view in self.subviews) {
            
            view.frame = CGRectMake(self.frame.size.width - view.frame.origin.x - view.frame.size.width, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
            if ([view isKindOfClass:[UILabel class]]) {
                
                ((UILabel *)view).textAlignment = NSTextAlignmentRight;
            }
        }
    }
}

@end
