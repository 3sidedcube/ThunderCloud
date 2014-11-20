//
//  TSCCheckableListItemView.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 03/10/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCCheckableListItem.h"
#import "TSCLink.h"
#import "TSCEmbeddedLinksInputCheckItemCell.h"

@import ThunderBasics;

@implementation TSCCheckableListItem

- (id)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject
{
    if (self = [super initWithDictionary:dictionary parentObject:parentObject]) {
        
        self.title = TSCLanguageDictionary(dictionary[@"title"]);
        self.checkIdentifier = dictionary[@"id"];
        
    }
    
    return self;
}

#pragma Table Row Data Source

- (Class)tableViewCellClass
{
    return [TSCTableInputCheckViewCell class];
}

- (NSString *)rowTitle
{
    return self.title;
}

- (NSString *)rowSubtitle
{
    return self.subtitle;
}

- (UIImage *)rowImage
{
    return self.image;
}

- (TSCLink *)rowLink
{
    return nil;
}

- (BOOL)shouldDisplaySelectionCell
{
    return YES;
}

- (BOOL)shouldDisplaySelectionIndicator
{
    return NO;
}

- (SEL)rowSelectionSelector
{
    return nil;
}

- (id)rowSelectionTarget
{
    return nil;
}

- (UITableViewCell *)tableViewCell:(UITableViewCell *)cell;
{
    TSCTableInputCheckViewCell *checkCell = (TSCTableInputCheckViewCell *)cell;
    checkCell.checkView.checkIdentifier = self.checkIdentifier;
    self.checkView = checkCell.checkView;
    
    return checkCell;
}

@end
