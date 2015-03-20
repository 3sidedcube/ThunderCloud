//
//  TSCSpotlightListItem.h
//  ThunderCloud
//
//  Created by Matthew Cheetham on 20/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

#import "TSCListItem.h"

/**
 `TSCSpotlightListItem` is a representation of a spotlight view in a list page, it acts as a `TSCTableRowDataSource`
 */
@interface TSCSpotlightListItem : TSCListItem <TSCTableRowDataSource>

/**
 @abstract An arrary of `TSCSpotlight`s to be displayed inside the view
 */
@property (nonatomic, strong) NSArray *spotlights;


@end
