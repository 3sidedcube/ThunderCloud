//
//  TSCAnimatedImageListItemView.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 29/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCImageListItem.h"
#import "TSCAnimatedTableImageViewCell.h"

@interface TSCAnimatedImageListItemView : TSCImageListItem

@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSMutableArray *delays;

@end
