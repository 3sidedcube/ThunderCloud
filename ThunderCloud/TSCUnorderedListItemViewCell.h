//
//  TSCBulletListItemViewCell.h
//  ThunderCloud
//
//  Created by Phillip Caudell on 09/04/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import "TSCEmbeddedLinksListItemCell.h"
@import ThunderTable;

/**
 `TSCUnorderedListItemViewCell` is a subclass of `TSCEmbeddedLinksListItemCell` it reprents a cell that is in an unordered list. Normally used as a bullet list.
 */
@interface TSCUnorderedListItemViewCell : TSCEmbeddedLinksListItemCell

/**
 @abstract A `UIView` that looks like a bullet point
 */
@property (nonatomic, strong) UIView *bulletView;

@end
