//
//  TSCSpotlightView.h
//  ThunderStorm
//
//  Created by Andrew Hart on 11/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCStandardListItemView.h"

@interface TSCSpotlightImageListItemView : TSCStandardListItemView <TSCTableRowDataSource>

@property (nonatomic, strong) NSMutableArray *items;

@end