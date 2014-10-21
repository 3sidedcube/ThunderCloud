//
//  TSCTableHUDButtonRow.m
//  ThunderStorm
//
//  Created by Andrew Hart on 04/02/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import "TSCHUDButtonListItemView.h"
#import "TSCInlineButton.h"
#import "TSCLink.h"
#import "UINavigationController+TSCNavigationController.h"

@implementation TSCHUDButtonListItemView

- (Class)tableViewCellClass
{
    return [TSCTableHUDButtonViewCell class];
}

- (UITableViewCell *)tableViewCell:(UITableViewCell *)cell;
{
    TSCTableHUDButtonViewCell *standardCell = (TSCTableHUDButtonViewCell *)cell;
    standardCell.textLabel.text = @"";
    standardCell.detailTextLabel.text = @"";
    standardCell.delegate = self;
    
    self.parentNavigationController = standardCell.parentViewController.navigationController;
    
    TSCInlineButton *button = [[TSCInlineButton alloc] init];
    //button.title = @"Get £5 off baby and child first aid";
    button.title = self.link.title;
    button.link = self.link;
    self.buttons = @[button];
    
//    [standardCell resetButtonViewsFromButtons:@[button]];
    
    return standardCell;
}

- (BOOL)shouldDisplaySelectionCell
{
    return NO;
}

- (BOOL)shouldDisplaySelectionIndicator
{
    return NO;
}

- (id)rowSelectionTarget
{
    return nil;
}

- (SEL)rowSelectionSelector
{
    return nil;
}

#pragma mark - TSCTableHUDButtonViewCellDelegate methods

-(void)hudButtonViewCell:(TSCTableHUDButtonViewCell *)cell buttonPressedAtIndex:(NSInteger)index {
    if (index > self.buttons.count) {
        return;
    }
    
    TSCInlineButton *button = [self.buttons objectAtIndex:index];
    
    self.link = button.link;
    
    //if ([self.parentObject respondsToSelector:@selector(handleSelection:)]) {
    if ([self.parentNavigationController respondsToSelector:@selector(pushLink:)]) {
        [self.parentNavigationController pushLink:self.link];
    }
    //}
}

@end
