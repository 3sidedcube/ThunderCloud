//
//  TSCTextListItemView.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 27/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCTextListItemView.h"
#import "TSCTextListItemViewCell.h"

@implementation TSCTextListItemView

- (TSCTextListItemViewCell *)tableViewCell:(TSCTextListItemViewCell *)cell
{
    return cell;
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
