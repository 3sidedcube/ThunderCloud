//
//  TSCTextListItemViewCell.m
//  ThunderStorm
//
//  Created by Simon Mitchell on 29/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCTextListItemViewCell.h"

#define TEXT_LIST_ITEM_VIEW_TEXT_INSET 12

@implementation TSCTextListItemViewCell

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialSetupTextListItemViewCell];
    }
    
    return self;
}

- (id)init
{
    if (self = [super init]) {
        [self initialSetupTextListItemViewCell];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initialSetupTextListItemViewCell];
    }
    
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initialSetupTextListItemViewCell];
    }
    
    return self;
}

- (void)initialSetupTextListItemViewCell
{
    self.detailTextLabel.font = [UIFont systemFontOfSize:18];
    self.detailTextLabel.textColor = [UIColor darkGrayColor];
    self.detailTextLabel.textAlignment = NSTextAlignmentCenter;
    
    [self setupDetailTextLabelFrame];
}

- (void)setupDetailTextLabelFrame
{
    CGSize size = [self.detailTextLabel sizeThatFits:CGSizeMake(self.frame.size.width - (TEXT_LIST_ITEM_VIEW_TEXT_INSET * 2), MAXFLOAT)];
    
    self.detailTextLabel.frame = CGRectMake(TEXT_LIST_ITEM_VIEW_TEXT_INSET, TEXT_LIST_ITEM_VIEW_TEXT_INSET / 2, size.width, size.height + TEXT_LIST_ITEM_VIEW_TEXT_INSET);
    
    if (![TSCThemeManager isOS7]) {
        self.detailTextLabel.center = CGPointMake(self.frame.size.width / 2 - 5, self.detailTextLabel.center.y);
    } else {
        self.detailTextLabel.center = CGPointMake(self.frame.size.width / 2, self.detailTextLabel.center.y);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setupDetailTextLabelFrame];
    
    self.shouldDisplaySeparators = YES;
}

@end
