//
//  TSCTextListItemView.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 27/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCTextListItem.h"
#import "TSCTextListItemViewCell.h"

@implementation TSCTextListItem

- (TSCTextListItemViewCell *)tableViewCell:(TSCTextListItemViewCell *)cell
{
    return cell;
}

- (UIColor *)rowTitleTextColor
{
    return [UIColor darkGrayColor];
}

- (Class)tableViewCellClass
{
    return [TSCTextListItemViewCell class];
}

- (BOOL)shouldDisplaySelectionCell
{
    return NO;
}

- (BOOL)shouldDisplaySelectionIndicator
{
    return NO;
}

@end
