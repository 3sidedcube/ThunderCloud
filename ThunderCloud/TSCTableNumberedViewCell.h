//
//  TSCTableNumberedViewCell.h
//  ThunderStorm
//
//  Created by Phillip Caudell on 10/10/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCEmbeddedLinksListItemCell.h"

/**
 `TSCTableNumberedViewCell` is used to display cells in an ordered list
 */
@interface TSCTableNumberedViewCell : TSCEmbeddedLinksListItemCell

/**
 @abstract A `UILabel` that displays the number of the cell. Sits on the left hand side of the cell.
 */
@property (nonatomic, strong) UILabel *numberLabel;

@end
