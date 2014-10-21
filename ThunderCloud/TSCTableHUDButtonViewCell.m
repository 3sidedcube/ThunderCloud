//
//  TSCTableHUDButtonViewCell.m
//  ThunderStorm
//
//  Created by Andrew Hart on 04/02/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import "TSCTableHUDButtonViewCell.h"
#import "TSCHUDButton.h"
#import "TSCInlineButton.h"

@interface TSCTableHUDButtonViewCell ()

@end

@implementation TSCTableHUDButtonViewCell

-(void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundColor = [UIColor clearColor];
}

- (void)resetButtonViewsFromButtons:(NSArray *)buttons
{
    for (UIButton *view in self.buttonViews) {
        [view removeFromSuperview];
    }
    
    NSMutableArray *array = [NSMutableArray new];
    
    for (TSCInlineButton *button in buttons) {
        NSUInteger index = [buttons indexOfObject:button];
        TSCHUDButton *buttonView = [[TSCHUDButton alloc] init];
        buttonView.hudButtonType = HUDButtonTypeRed;
        buttonView.tag = index;
        [buttonView addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [buttonView setTitle:button.title forState:UIControlStateNormal];
        
        [self.contentView addSubview:buttonView];
        [array addObject:buttonView];
        
        //buttonView.button = button;
        //buttonView.interactionDelegate = self;
    }
    
    self.buttonViews = array;
}

-(void)buttonPressed:(UIButton *)button {
    [self.delegate hudButtonViewCell:self buttonPressedAtIndex:button.tag];
}

@end
