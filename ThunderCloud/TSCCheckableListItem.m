//
//  TSCCheckableListItemView.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 03/10/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCCheckableListItem.h"
#import "TSCLink.h"
#import "TSCStormStyler.h"
@import ThunderBasics;

@implementation TSCCheckableListItem

- (id)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject styler:(TSCStormStyler *)styler
{
    self = [super init];
    
    if (self) {
        
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
    return self.link;
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
    return NSSelectorFromString(@"handleCheckFromTableSelection:");
}

- (id)rowSelectionTarget
{
    return self.cell;
}

- (UITableViewCell *)tableViewCell:(UITableViewCell *)cell;
{
    TSCTableInputCheckViewCell *checkCell = (TSCTableInputCheckViewCell *)cell;
    self.cell = checkCell;
    self.cell.checkView.checkIdentifier = self.checkIdentifier;
    [self.cell.checkView setOn:[[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"TSCCheckItem%@", self.checkIdentifier]] animated:NO];
    
    return checkCell;
}

@end
