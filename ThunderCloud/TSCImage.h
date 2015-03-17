//
//  TSCImage.h
//  ThunderStorm
//
//  Created by Phillip Caudell on 10/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A helper class for intiailizing `UIImage`s from their CMS representatioon and applying visual effects to images
 */
@interface TSCImage : UIImage

/**
 Initializes a new instance from a CMS representation of an image
 @param dictionary The dictionary to create an image from
 @discussion This will pull out the correct image from the dictionary for use on a particular scale display (@1x, @2x, @3x)
 */
+ (UIImage *)imageWithDictionary:(NSDictionary *)dictionary;

/**
 Adds a light blur effect to a frame within the image
 @param frame The frame over which to apply the light blur
 */
- (UIImage *)applyLightEffectAtFrame:(CGRect)frame;

/**
 Adds an extra light blur effect to a frame within the image
 @param frame The frame over which to apply the extra light blur
 */
- (UIImage *)applyExtraLightEffectAtFrame:(CGRect)frame;

/**
 Adds an dark blur effect to a frame within the image
 @param frame The frame over which to apply the dark  blur
 */
- (UIImage *)applyDarkEffectAtFrame:(CGRect)frame;

/**
 Adds an tint effect to a frame within the image
 @param tintColor The colour to tint the area of the image with
 @param frame The frame over which to apply the tint
 */
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor atFrame:(CGRect)frame;

@end
