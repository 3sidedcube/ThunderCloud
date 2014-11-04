//
//  TSCDescriptionListItemView.m
//  ThunderStorm
//
//  Created by Simon Mitchell on 13/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCDescriptionListItem.h"
#import "TSCEmbeddedLinksListItemCell.h"

@implementation TSCDescriptionListItem

- (UIImage *)rowImage
{
    return nil;
}

- (TSCEmbeddedLinksListItemCell *)tableViewCell:(TSCEmbeddedLinksListItemCell *)cell
{
    cell = (TSCEmbeddedLinksListItemCell *)[super tableViewCell:cell];
    if (![self rowImage]) {
        for (UIView *view in cell.contentView.subviews) {
            if ([view isMemberOfClass:[UIImageView class]]) {
                [view removeFromSuperview];
            }
        }
    }
    
    return cell;
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
