//
//  TSCStandardListItemView.h
//  ThunderStorm
//
//  Created by Phillip Caudell on 27/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@class TSCLink;

#import "TSCStormObject.h"
#import "TSCEmbeddedLinksListItemCell.h"

/**
 `TSCListItem` is the base object for displaying table rows in storm. It complies to `TSCTableRowDataSource`.
 */
@interface TSCListItem : TSCStormObject <TSCTableRowDataSource>

/**
 @abstract The title of the row
 */
@property (nonatomic, copy) NSString *title;

/**
 @abstract The subtitle title of the row
 @discussion The subtitle gets displayed underneath the title
 */
@property (nonatomic, copy) NSString *subtitle;

/**
 @abstract A `TSCLink` which determines what the row does when it is selected
 */
@property (nonatomic, strong) TSCLink *link;

/**
 @abstract The image for the row
 @discussion This is displayed on the right hand side of the cell
 */
@property (nonatomic, strong) UIImage *image;

/**
 @abstract The `UINavigationController` of the view controller the row is contained in.
 */
@property (nonatomic, strong) UINavigationController *parentNavigationController;

@end
