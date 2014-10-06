//
//  TSCTextListItemViewCell.m
//  ThunderStorm
//
//  Created by Andrew Hart on 29/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCTextListItemViewCell.h"

#define TEXT_LIST_ITEM_VIEW_TEXT_INSET 12

@implementation TSCTextListItemViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initialSetupTextListItemViewCell];
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        [self initialSetupTextListItemViewCell];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initialSetupTextListItemViewCell];
    }
    
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self initialSetupTextListItemViewCell];
    }
    
    return self;
}

- (void)initialSetupTextListItemViewCell
{
    self.detailTextLabel.font = [UIFont systemFontOfSize:18];
    //self.detailTextLabel.textColor = [UIColor whiteColor];
    self.detailTextLabel.textColor = [UIColor darkGrayColor];
    self.detailTextLabel.textAlignment = NSTextAlignmentCenter;
    //self.backgroundColor = [UIColor colorWithWhite:0.35 alpha:1.0];
    
    //self.backgroundColor = [UIColor clearColor];
    
    [self setupDetailTextLabelFrame];
}

- (void)setupDetailTextLabelFrame
{
    CGSize size = [self.detailTextLabel.text sizeWithFont:self.detailTextLabel.font constrainedToSize:CGSizeMake(self.frame.size.width - (TEXT_LIST_ITEM_VIEW_TEXT_INSET * 2), 100000) lineBreakMode:NSLineBreakByWordWrapping];
    
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
}

@end
