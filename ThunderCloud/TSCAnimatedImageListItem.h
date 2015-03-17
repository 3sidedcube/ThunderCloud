//
//  TSCAnimatedImageListItemView.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 29/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCImageListItem.h"
#import "TSCAnimatedTableImageViewCell.h"

/**
 A subclass of `TSCImageListItem` which displays an array of animated images at the aspect ratio of the first image in the set, delaying between each one by a defined amount of time
 */
@interface TSCAnimatedImageListItem : TSCImageListItem

/**
 @abstract The array of images to animate
 */
@property (nonatomic, strong) NSMutableArray *images;

/**
 @abstract An array of delays to apply between each consecutive frame of the animated image
 */
@property (nonatomic, strong) NSMutableArray *delays;

@end
