//
//  TSCTextField.m
//  ThunderCloud
//
//  Created by Simon Mitchell on 18/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

#import "TSCTextField.h"

@implementation TSCTextField

- (instancetype)init
{
    if (self = [super init]) {
        self.textInsets = CGSizeMake(8, 0);
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.textInsets = CGSizeMake(8, 0);
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, self.textInsets.width, self.textInsets.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, self.textInsets.width, self.textInsets.height);
}

@end
