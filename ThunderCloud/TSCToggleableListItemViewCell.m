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

@end

@implementation TSCToggleableListItemViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
    }
    
    return self;
}

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
    
    CGSize size = [self.detailTextLabel sizeThatFits:CGSizeMake(self.frame.size.width - (TEXT_LIST_ITEM_VIEW_TEXT_INSET * 2), MAXFLOAT)];
    
    if([TSCThemeManager localisedTextDirectionForBaseDirection:NSTextAlignmentLeft] == NSTextAlignmentRight){
        
        self.detailTextLabel.frame = CGRectMake(-TEXT_LIST_ITEM_VIEW_TEXT_INSET, self.textLabel.frame.size.height + self.textLabel.frame.origin.y + TEXT_LIST_ITEM_VIEW_TEXT_INSET / 2, size.width, size.height + TEXT_LIST_ITEM_VIEW_TEXT_INSET);
        
    } else {
        
        self.detailTextLabel.frame = CGRectMake(TEXT_LIST_ITEM_VIEW_TEXT_INSET, self.textLabel.frame.size.height + self.textLabel.frame.origin.y + TEXT_LIST_ITEM_VIEW_TEXT_INSET / 2, size.width, size.height + TEXT_LIST_ITEM_VIEW_TEXT_INSET);
    }
    
    [self.detailTextLabel setFont:[UIFont systemFontOfSize:14]];
}

@end
