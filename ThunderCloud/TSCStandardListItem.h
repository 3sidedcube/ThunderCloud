//
//  TSCStandardListItemView.h
//  ThunderStorm
//
//  Created by Phillip Caudell on 27/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@class TSCLink;

#import "TSCStormObject.h"
#import "TSCTableButtonViewCell.h"

@interface TSCStandardListItem : TSCStormObject <TSCTableRowDataSource>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, strong) TSCLink *link;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UINavigationController *parentNavigationController;

/*
@property (nonatomic, strong) NSArray *buttons;
 */

@end
