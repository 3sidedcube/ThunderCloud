//
//  TSCAnimationFrame.h
//  ThunderCloud
//
//  Created by Matthew Cheetham on 20/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSCImage.h"

/**
 A single frame of a `TSCAnimation`. These frames are used to create an animation
 */
@interface TSCAnimationFrame : NSObject

/**
 @abstract The delay in miliseconds before the next frame
 */
@property (nonatomic, strong) NSNumber *delay;

/**
 @abstract The image to display on screen when this frame is activated
 */
@property (nonatomic, strong) UIImage *image;

@end
