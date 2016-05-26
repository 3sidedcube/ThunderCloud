//
//  TSCLinkCollectionCell.h
//  ThunderCloud
//
//  Created by Simon Mitchell on 28/10/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

@import UIKit;
@import ThunderTable;
#import "TSCCollectionCell.h"

/**
 A subclass of `TSCTableViewCell` which displays the user a collection view containing a list of links.
 Links in this collection view are displayed as their image
 */
@interface TSCLinkCollectionCell : TSCCollectionCell

/**
 @abstract The array of `TSCLink`s to display in the cell
 */
@property (nonatomic, strong) NSArray *links;

@end
