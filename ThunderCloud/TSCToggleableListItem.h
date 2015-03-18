//
//  TSCToggleableListItemView.h
//  ThunderStorm
//
//  Created by Phillip Caudell on 27/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCEmbeddedLinksListItem.h"

/**
 `TSCEmbeddedLinksListItem` is a `TSCEmbeddedLinksListItem` when the row is selected it opens up to reveal more content.
 */
@interface TSCToggleableListItem : TSCEmbeddedLinksListItem

/**
 @abstract A BOOL to determine whether the row is displaying its hidden content.
 */
@property (nonatomic) BOOL isFullyVisible;

@end
