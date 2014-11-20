//
//  TSCToggleableListItemViewCell.m
//  ThunderStorm
//
//  Created by Simon Mitchell on 11/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCToggleableListItemViewCell.h"

#define TEXT_LIST_ITEM_VIEW_TEXT_INSET 12

@interface TSCToggleableListItemViewCell ()

@property (nonatomic, strong) NSString *detailsText;
@property UIButton *toggleButton;
@property UIView *toggleContainerView;

@end

@implementation TSCToggleableListItemViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.toggleButton.frame = CGRectMake(0, 0, 16, 11);
        
        self.toggleContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 14, 11, self.frame.size.height - 28)];
        [self.toggleContainerView addSubview:self.toggleButton];
        
        [self.detailTextLabel setFont:[UIFont systemFontOfSize:14]];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if([TSCThemeManager localisedTextDirectionForBaseDirection:NSTextAlignmentLeft] == NSTextAlignmentRight) {
        
        [self.toggleContainerView removeFromSuperview];
        
        [self.contentView addSubview:self.toggleContainerView];
        self.toggleContainerView.frame = CGRectMake(14, 20, 11, self.frame.size.height - 28);
        
    } else {
        
        self.accessoryView = self.toggleContainerView;
        self.toggleContainerView.frame = CGRectMake(self.toggleContainerView.frame.origin.x, self.toggleContainerView.frame.origin.y, self.toggleContainerView.frame.size.width, self.frame.size.height - 28);
    }
    
    CGSize size = [self.detailTextLabel sizeThatFits:CGSizeMake(self.frame.size.width - (TEXT_LIST_ITEM_VIEW_TEXT_INSET * 2), MAXFLOAT)];
    
    if (self.isFullyVisible) {
        
        if (self.textLabel.frame.origin.y < 10) {
            self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, self.textLabel.frame.origin.y + 10, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
        }
        
        if([TSCThemeManager localisedTextDirectionForBaseDirection:NSTextAlignmentLeft] == NSTextAlignmentRight){
            
            self.detailTextLabel.frame = CGRectMake(-TEXT_LIST_ITEM_VIEW_TEXT_INSET, self.textLabel.frame.size.height + self.textLabel.frame.origin.y, size.width, size.height + TEXT_LIST_ITEM_VIEW_TEXT_INSET);
        } else {
            
            self.detailTextLabel.frame = CGRectMake(TEXT_LIST_ITEM_VIEW_TEXT_INSET, self.textLabel.frame.size.height + self.textLabel.frame.origin.y, size.width, size.height + TEXT_LIST_ITEM_VIEW_TEXT_INSET);
        }
    }
    
    [self.detailTextLabel setFont:[UIFont systemFontOfSize:14]];
}

- (void)setIsFullyVisible:(BOOL)isFullyVisible
{
    _isFullyVisible = isFullyVisible;
    if (!_isFullyVisible) {
        
        self.detailTextLabel.text = @"";
        if ([TSCThemeManager isOS8]) {
            [self.toggleButton setImage:[UIImage imageNamed:@"chevron-down" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        } else {
            [self.toggleButton setImage:[UIImage imageNamed:@"chevron-down"] forState:UIControlStateNormal];
        }
    } else {
        
        if ([TSCThemeManager isOS8]) {
            [self.toggleButton setImage:[UIImage imageNamed:@"chevron-up" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        } else {
            [self.toggleButton setImage:[UIImage imageNamed:@"chevron-up"] forState:UIControlStateNormal];
        }
    }
}

@end
