//
//  TSCSpotlightImageListItemViewItem.h
//  ThunderStorm
//
//  Created by Andrew Hart on 11/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCStormObject.h"
@import UIKit;

@class TSCLink;

@interface TSCSpotlightImageListItemViewItem : TSCStormObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) TSCLink *link;
@property (assign) NSInteger delay;
@property (nonatomic, copy) NSString *spotlightText;

@end
