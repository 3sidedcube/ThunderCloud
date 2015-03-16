//
//  TSCCheckableListItemView.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 03/10/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCEmbeddedLinksListItem.h"

@class TSCEmbeddedLinksInputCheckItemCell;
@import UIKit;
@import ThunderTable;

@interface TSCCheckableListItem : TSCEmbeddedLinksListItem

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) TSCLink *link;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSNumber *checkIdentifier;
@property (nonatomic, strong) TSCCheckView *checkView;

@property (nonatomic, strong) TSCTableInputCheckViewCell *cell;


@end
