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
        self.checkView = [[TSCCheckView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [self.checkView addTarget:self action:@selector(handleCheck:) forControlEvents:UIControlEventValueChanged];
        self.checkView.userInteractionEnabled = NO;
    }
    
    return self;
}

#pragma Table Row Data Source

- (Class)tableViewCellClass
{
    return [TSCEmbeddedLinksInputCheckItemCell class];
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
    return NSSelectorFromString(@"handleCheckFromTableSelection:");
}

- (id)rowSelectionTarget
{
    return self;
}

- (UITableViewCell *)tableViewCell:(UITableViewCell *)cell;
{
    TSCEmbeddedLinksInputCheckItemCell *checkCell = (TSCEmbeddedLinksInputCheckItemCell *)cell;
    checkCell.checkView = self.checkView;
    checkCell.checkView.checkIdentifier = self.checkIdentifier;
    
    checkCell.links = self.embeddedLinks;
    
    return checkCell;
}

- (void)handleCheckFromTableSelection:(TSCTableSelection *)selection
{
    [self handleCheck:self.checkView];
    [self.checkView setOn:!self.checkView.isOn animated:YES saveState:YES];
}

- (void)handleCheck:(TSCCheckView *)sender
{
    self.cell.inputRow.value = [NSNumber numberWithBool:sender.isOn];
}

@end
