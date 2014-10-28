//
//  TSCCheckableListItemView.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 03/10/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCListItem.h"
@class TSCTableInputCheckViewCell;
@import UIKit;
@import ThunderTable;

@interface TSCCheckableListItem : TSCListItem

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, strong) TSCLink *link;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSNumber *checkIdentifier;
@property (nonatomic, strong) TSCCheckView *checkView;

@property (nonatomic, strong) TSCTableInputCheckViewCell *cell;


@end
