//
//  TSCTableButtonViewCell.m
//  ThunderStorm
//
//  Created by Phillip Caudell on 04/12/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCTableButtonViewCell.h"
#import "TSCInlineButton.h"
#import "TSCInlineButtonView.h"
#import "TSCButtonListItemViewCell.h"

@interface TSCTableButtonViewCell () <TSCInlineButtonViewInteractionDelegate>


@end

@implementation TSCTableButtonViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    float textLabelWidth = self.bounds.size.width - 30;
    float detailTextLabelWidth = self.bounds.size.width - 30;
    
    if (self.accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
        textLabelWidth = self.bounds.size.width - self.imageView.frame.size.width - 60;
        detailTextLabelWidth = self.bounds.size.width - self.imageView.frame.size.width - 60;
    }
    
    self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, 12, textLabelWidth, self.textLabel.frame.size.height);
    
    float detailTextLabelY = 12;
    
    if (self.textLabel.text.length > 0) {
        detailTextLabelY = self.textLabel.frame.origin.y + self.textLabel.frame.size.height + 4;
    }
    
    self.detailTextLabel.frame = CGRectMake(self.detailTextLabel.frame.origin.x, detailTextLabelY, detailTextLabelWidth, self.detailTextLabel.frame.size.height);
    
    self.textLabel.textAlignment = self.detailTextLabel.textAlignment = [TSCThemeManager localisedTextDirectionForBaseDirection:NSTextAlignmentLeft];
    
    [self layoutButtons];
    
}

-(void)layoutButtons {
    
    float buttonY = 12;
    
    if (self.textLabel.text.length > 0) {
        buttonY = MAX(buttonY, self.textLabel.frame.origin.y + self.textLabel.frame.size.height + 8);
    }
    
    if (self.detailTextLabel.text.length > 0) {
        buttonY = MAX(buttonY, self.detailTextLabel.frame.origin.y + self.detailTextLabel.frame.size.height + 8);
    }
    
    for (UIButton *button in self.buttonViews) {
        
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
    }
}

- (void)resetButtonViewsFromButtons:(NSArray *)buttons
{
    for (TSCInlineButtonView *view in self.buttonViews) {
        [view removeFromSuperview];
    }
    
    NSMutableArray *array = [NSMutableArray new];
    
    for (TSCInlineButton *button in buttons) {
        //int index = [buttons indexOfObject:button];
        TSCInlineButtonView *buttonView = [[TSCInlineButtonView alloc] init];
        buttonView.button = button;
        buttonView.interactionDelegate = self;
        //buttonView.tag = index;
        //[buttonView addTarget:self action:@selector(handleButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        
        if (!buttonView.buttonDisabledReason == ButtonDisabledReasonCallsNotSupported) {
            [self.contentView addSubview:buttonView];
            [array addObject:buttonView];
        }
    }
    
    self.buttonViews = array;
}

#pragma mark - TSCInlineButtonViewInteractionDelegate methods

-(void)inlineButtonWasTapped:(TSCInlineButtonView *)button {
    [self.cellDelegate button:button wasTappedInCell:self];
}

@end
