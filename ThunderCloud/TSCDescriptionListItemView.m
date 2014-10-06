//
//  TSCDescriptionListItemView.m
//  ThunderStorm
//
//  Created by Andrew Hart on 13/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCDescriptionListItemView.h"

@implementation TSCDescriptionListItemView

- (UIImage *)rowImage
{
    return nil;
}

- (TSCTableButtonViewCell *)tableViewCell:(TSCTableButtonViewCell *)cell
{
    
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
