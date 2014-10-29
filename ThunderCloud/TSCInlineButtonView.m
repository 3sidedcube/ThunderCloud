//
//  TSCButtonView.m
//  ThunderStorm
//
//  Created by Simon Mitchell on 12/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCInlineButtonView.h"
#import "TSCLink.h"

@interface TSCInlineButtonView ()

@end

@implementation TSCInlineButtonView

- (instancetype)init
{
    if (self = [super init]) {
        
        self.layer.cornerRadius = 8.0;
        
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (void)layoutSubviews
{
    self.titleLabel.frame = self.bounds;
}

#pragma mark - Setter methods

- (void)setLink:(TSCLink *)link
{
    _link = link;
    [self setTitle:link.title forState:UIControlStateNormal];
}

@end