//
//  TSCToggleableListItemView.m
//  ThunderStorm
//
//  Created by Phillip Caudell on 27/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCToggleableListItem.h"
#import "TSCToggleableListItemViewCell.h"

#define DEGREES_TO_RADIANS(x) (x * M_PI / 180.0)

@implementation TSCToggleableListItem

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super initWithDictionary:dictionary]) {
        
        self.isFullyVisible = NO;
    }
    
    return self;
}

- (id)rowSelectionTarget
{
    if (self.link) {
        return self.parentObject;
    } else {
        return self;
    }
}

- (SEL)rowSelectionSelector
{
    if (self.link) {
        return NSSelectorFromString(@"handleSelection:");
    } else {
        return @selector(resizeCell:);
    }
}

- (UITableViewCell *)tableViewCell:(UITableViewCell *)cell
{
    TSCToggleableListItemViewCell *toggleCell = (TSCToggleableListItemViewCell *)cell;
    
    if (self.isFullyVisible) {
        toggleCell.detailTextLabel.text = self.subtitle;
    }
    toggleCell.isFullyVisible = self.isFullyVisible;
    
    return toggleCell;
}

- (Class)tableViewCellClass
{
    return [TSCToggleableListItemViewCell class];
}

- (BOOL)shouldDisplaySelectionIndicator
{
    return NO;
}

- (void)resizeCell:(TSCTableSelection *)selection
{
    self.isFullyVisible = !self.isFullyVisible;
    
    [selection.tableView reloadRowsAtIndexPaths:@[selection.indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Setter methods

- (void)setIsFullyVisible:(BOOL)isFullyVisible
{
    _isFullyVisible = isFullyVisible;
}

@end