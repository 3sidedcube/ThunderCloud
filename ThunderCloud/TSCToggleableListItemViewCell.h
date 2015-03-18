//
//  TSCToggleableListItemViewCell.h
//  ThunderStorm
//
//  Created by Simon Mitchell on 11/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCEmbeddedLinksListItemCell.h"

/**
 `TSCToggleableListItemViewCell` is a `TSCEmbeddedLinksListItemCell` when the cell is selected it opens up to reveal the detail text label.
 */
@interface TSCToggleableListItemViewCell : TSCEmbeddedLinksListItemCell

/**
 @abstract A BOOL to determine whether the cell is displaying the detail text label.
 */
@property (nonatomic, assign) BOOL isFullyVisible;

@end
