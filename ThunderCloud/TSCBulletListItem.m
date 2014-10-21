//
//  TSCBulletListItemView.m
//  ThunderCloud
//
//  Created by Phillip Caudell on 09/04/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import "TSCBulletListItem.h"
#import "TSCBulletListItemViewCell.h"

@implementation TSCBulletListItem

- (Class)tableViewCellClass
{
    return [TSCBulletListItemViewCell class];
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
