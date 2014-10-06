//
//  TSCCustomUploadListItemView.m
//  ThunderStorm
//
//  Created by Sam Houghton on 19/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCCustomUploadListItemView.h"

@implementation TSCCustomUploadListItemView

- (UITableViewCell *)tableViewCell:(UITableViewCell *)cell
{
    UITableViewCell *groupCell = (UITableViewCell *)cell;
    
    return groupCell;
}

- (CGFloat)tableViewCellHeightConstrainedToSize:(CGSize)contrainedSize
{
    if ([TSCThemeManager isOS7]) {
        return 90;
    } else {
        return 118;
    }
}

@end
