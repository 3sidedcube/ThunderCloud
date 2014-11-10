//
//  TSCListItemView.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 27/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCTitleListItem.h"

@implementation TSCTitleListItem

- (BOOL)shouldDisplaySelectionIndicator
{
    return self.link != nil;
}

@end
