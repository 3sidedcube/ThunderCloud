//
//  TSCAnimationListItem.h
//  ThunderCloud
//
//  Created by Matthew Cheetham on 20/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

#import "TSCImageListItem.h"
#import "TSCAnimation.h"

/**
 A subclass of `TSCImageListItem` which displays an array of animated images at the aspect ratio of the first image in the set, delaying between each one by a defined amount of time
 */
@interface TSCAnimationListItem : TSCImageListItem

/**
 @abstract The animation object that contains frame information
 */
@property (nonatomic, strong) TSCAnimation *animation;

@end
