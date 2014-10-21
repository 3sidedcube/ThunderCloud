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

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    
    if (self) {
        
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
        return @selector(handleSelection:);
    } else {
        return @selector(resizeCell:);
    }
}

- (UITableViewCell *)tableViewCell:(UITableViewCell *)cell
{
    TSCToggleableListItemViewCell *toggleCell = (TSCToggleableListItemViewCell *)cell;
    
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 14, 11, toggleCell.frame.size.height - 28);
    view.tag = 338;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 11, 11);
    
    if (!self.isFullyVisible) {
        toggleCell.detailTextLabel.text = @"";
        [button setImage:[UIImage imageNamed:@"chevron-down"] forState:UIControlStateNormal];
    } else {
        toggleCell.detailTextLabel.text = self.subtitle;
        [button setImage:[UIImage imageNamed:@"chevron-up"] forState:UIControlStateNormal];
    }
    
    [view addSubview:button];
    
    if([TSCThemeManager localisedTextDirectionForBaseDirection:NSTextAlignmentLeft] == NSTextAlignmentRight){
        
        for(UIView *view in cell.contentView.subviews){
            if(view.tag == 338){
                [view removeFromSuperview];
            }
        }
        
        [cell.contentView addSubview:view];
        view.frame = CGRectMake(14, 20, 11, toggleCell.frame.size.height - 28);
        
    } else {
        toggleCell.accessoryView = view;
    }
    
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
