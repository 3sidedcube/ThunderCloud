//
//  TSCSpotlightView.h
//  ThunderStorm
//
//  Created by Andrew Hart on 11/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCListItem.h"

@interface TSCSpotlightImageListItem : TSCListItem <TSCTableRowDataSource>

@property (nonatomic, strong) NSMutableArray *items;

@end