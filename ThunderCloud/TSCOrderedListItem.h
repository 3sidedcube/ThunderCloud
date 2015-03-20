//
//  TSCAnnotatedListItemView.h
//  ThunderStorm
//
//  Created by Phillip Caudell on 27/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCEmbeddedLinksListItem.h"

/**
 `TSCOrderedListItem` is a subclass of `TSCEmbeddedLinksListItem` it reprents a table item that has a number on the left. They will always be in the correct order from the cms. e.g. 1, 2, 3
 */
@interface TSCOrderedListItem : TSCEmbeddedLinksListItem

@property (nonatomic, copy) NSString *number;

@end
