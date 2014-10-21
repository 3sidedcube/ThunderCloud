//
//  TSCAnnotatedListItemView.m
//  ThunderStorm
//
//  Created by Phillip Caudell on 27/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCOrderedListItem.h"
#import "TSCTableNumberedViewCell.h"

@implementation TSCOrderedListItem

- (id)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject styler:(TSCStormStyler *)styler
{
    self = [super initWithDictionary:dictionary parentObject:parentObject styler:styler];
    
    if (self) {
        
        if(dictionary[@"annotation"] != [NSNull null]){
            self.number = dictionary[@"annotation"];
        }
        
    }
    
    return self;
}

- (Class)tableViewCellClass
{
    return [TSCTableNumberedViewCell class];
}

- (UITableViewCell *)tableViewCell:(UITableViewCell *)cell
{
    TSCTableNumberedViewCell *numberedCell = (TSCTableNumberedViewCell *)[super tableViewCell:cell];
    numberedCell.numberLabel.text = self.number;
    
    return numberedCell;
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
