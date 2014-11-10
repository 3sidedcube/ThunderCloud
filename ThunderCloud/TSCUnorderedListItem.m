//
//  TSCBulletListItemView.m
//  ThunderCloud
//
//  Created by Phillip Caudell on 09/04/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import "TSCUnorderedListItem.h"
#import "TSCUnorderedListItemViewCell.h"

@implementation TSCUnorderedListItem

- (Class)tableViewCellClass
{
    return [TSCUnorderedListItemViewCell class];
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
