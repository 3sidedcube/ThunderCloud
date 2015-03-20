//
//  TSCSpotlightListItem.h
//  ThunderCloud
//
//  Created by Matthew Cheetham on 20/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

#import "TSCListItem.h"

@interface TSCSpotlightListItem : TSCListItem <TSCTableRowDataSource>

/**
 @abstract An arrary of `TSCSpotlight`s to be displayed
 */
@property (nonatomic, strong) NSArray *spotlights;


@end
