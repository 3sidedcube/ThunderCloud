//
//  TSCButtonListItemViewCell.m
//  ThunderStorm
//
//  Created by Andrew Hart on 12/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCButtonListItemViewCell.h"

@interface TSCButtonListItemViewCell () <TSCInlineButtonViewInteractionDelegate>

@end

@implementation TSCButtonListItemViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    
    if (self) {
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutButtons];
    
    /*
    
    self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, 12, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
    
    float detailY = 12;
    
    if (self.textLabel.text.length > 0) {
        detailY = self.textLabel.frame.origin.y + self.textLabel.frame.size.height + 2;
    }
    
    self.detailTextLabel.frame = CGRectMake(self.detailTextLabel.frame.origin.x, detailY, self.detailTextLabel.frame.size.width, self.detailTextLabel.frame.size.height);
    
    float buttonY = 10;
    
    if (self.detailTextLabel.text.length > 0) {
        buttonY = buttonY + self.detailTextLabel.frame.origin.y + self.detailTextLabel.frame.size.height + 80;
    }
    
    if (self.textLabel.text.length > 0) {
        buttonY = MAX(buttonY, buttonY + self.textLabel.frame.origin.y + self.textLabel.frame.size.height + 8);
    }
    
    for (TSCInlineButtonView *button in self.buttonViews) {
        
        float x = 43;
        
        if (self.textLabel.text.length == 0) {
            x = 15;
        }
        
        float width = self.frame.size.width;
        
        if (![TSCThemeManager isOS7]) {
            width = width - 20;
            
            if (isPad()) {
                width = width - 70;
            }
        }
        
        button.frame = CGRectMake(x, buttonY, width - 15 - x, 46);
        
        buttonY = buttonY + 60;
    }*/
    
    
}
/*
- (void)resetButtonViewsFromButtons:(NSArray *)buttons
{
    for (TSCInlineButtonView *view in self.buttonViews) {
        [view removeFromSuperview];
    }
    
    NSMutableArray *array = [NSMutableArray new];
    
    for (TSCInlineButton *button in buttons) {
        TSCInlineButtonView *buttonView = [[TSCInlineButtonView alloc] init];
        buttonView.button = button;
        buttonView.interactionDelegate = self;
        
        if (!buttonView.buttonDisabledReason == ButtonDisabledReasonCallsNotSupported) {
            [self.contentView addSubview:buttonView];
            [array addObject:buttonView];
        }
    }
    
    self.buttonViews = array;
}*/

#pragma mark - TSCInlineButtonViewInteractionDelegate methods

- (void)inlineButtonWasTapped:(TSCInlineButtonView *)button
{
    [self.delegate button:button wasTappedInTSCButtonListItemViewCell:self];
}

@end