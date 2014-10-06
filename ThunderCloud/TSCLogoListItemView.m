//
//  TSCLogoListItemView.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 14/10/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCLogoListItemView.h"
#import "TSCLogoListItemViewCell.h"
@import ThunderBasics;

@implementation TSCLogoListItemView

- (id)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject styler:(TSCStormStyler *)styler
{
    self = [super initWithDictionary:dictionary parentObject:parentObject styler:styler];
    
    if (self) {
        self.title = TSCLanguageDictionary(dictionary[@"link"][@"title"]);
    }
    
    return self;
}

- (NSString *)rowTitle
{
    return @"Developed by 3 SIDED CUBE";
}

#pragma mark Row data source

- (Class)tableViewCellClass
{
    return [TSCLogoListItemViewCell class];
}

- (UITableViewCell *)tableViewCell:(UITableViewCell *)cell
{
    TSCLogoListItemViewCell *logoCell = (TSCLogoListItemViewCell *)cell;
    
    return logoCell;
}

- (CGFloat)tableViewCellHeightConstrainedToSize:(CGSize)contrainedSize;
{
    return 110;
}

- (BOOL)shouldDisplaySeperator
{
    return NO;
}

- (BOOL)shouldDisplaySelectionIndicator
{
    return NO;
}

@end
