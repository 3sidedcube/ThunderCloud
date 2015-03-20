//
//  TSCSpotlightListItem.m
//  ThunderCloud
//
//  Created by Matthew Cheetham on 20/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

#import "TSCSpotlightListItem.h"
#import "TSCSpotlight.h"
#import "TSCSpotlightImageListItemViewItem.h"
#import "TSCSpotlightImageListItemViewCell.h"
#import "UINavigationController+TSCNavigationController.h"
#import "TSCLink.h"
@import ThunderBasics;

@interface TSCSpotlightListItem () <TSCSpotlightImageListItemViewCellDelegate>

@end

@implementation TSCSpotlightListItem

- (instancetype)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject
{
    if (self = [super initWithDictionary:dictionary parentObject:parentObject]) {
        
        self.spotlights = [NSArray arrayWithArrayOfDictionaries:dictionary[@"spotlights"] rootInstanceType:[TSCSpotlight class]];

    }
    
    return self;
}

- (TSCSpotlightImageListItemViewCell *)tableViewCell:(TSCSpotlightImageListItemViewCell *)cell
{
    cell.items = self.spotlights;
    cell.delegate = self;
    self.parentNavigationController = cell.parentViewController.navigationController;
    
    return cell;
}

- (Class)tableViewCellClass
{
    return [TSCSpotlightImageListItemViewCell class];
}

- (SEL)rowSelectionSelector
{
    return NSSelectorFromString(@"handleSelection:");
}

- (id)rowSelectionTarget
{
    return self.parentObject;
}

- (TSCLink *)rowLink
{
    return self.link;
}

- (CGFloat)tableViewCellHeightConstrainedToSize:(CGSize)contrainedSize
{
    if (contrainedSize.width == 768) {
        return 380;
    } else if (contrainedSize.width >= 690) {
        return 380;
    }
    return 160;
}

- (BOOL)shouldDisplaySelectionIndicator
{
    return NO;
}

- (BOOL)shouldDisplaySelectionCell
{
    return NO;
}

#pragma mark - TSCSpotlightImageListItemViewCellDelegate methods

- (void)spotlightViewCell:(TSCSpotlightImageListItemViewCell *)cell didReceiveTapOnItemAtIndex:(NSInteger)index
{
    if (self.spotlights.count == 0) { // If an animated image cell has no images this fixes a crash
        return;
    }
    
    TSCSpotlightImageListItemViewItem *item = [self.spotlights objectAtIndex:index];
    
    if (item.link) {
        self.link = item.link;
        [self.parentNavigationController pushLink:self.link];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCStatEventNotification" object:self userInfo:@{@"type":@"Event", @"category":@"Spotlight", @"action":item.link.url.absoluteString}];
}

@end
