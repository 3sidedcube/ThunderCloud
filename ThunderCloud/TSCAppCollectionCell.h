//
//  TSCAppCollectionCell.h
//  ThunderCloud
//
//  Created by Matt Cheetham on 23/06/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

@import UIKit;
@import ThunderTable;

/**
 A subclass of `TSCTableViewCell` which displays the user a collection view containing a list of apps.
 Apps in this collection view are displayed as their app icon, with a price and name below them
 */
@interface TSCAppCollectionCell : TSCCollectionCell

/**
 @abstract The array of apps to be shown within the collection view
 */
@property (nonatomic, strong) NSArray *apps;

@end
