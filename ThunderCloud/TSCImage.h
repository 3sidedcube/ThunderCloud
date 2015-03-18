//
//  TSCImage.h
//  ThunderStorm
//
//  Created by Phillip Caudell on 10/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSCImage : UIImage

/**
 Takes a JSON object and returns the image from the bundle
 @discussion This image will consider the device scale and find the right image
 */
+ (UIImage *)imageWithJSONObject:(NSObject *)object;

/**
 Takes a dictionary object and returns the image from the bundle
 @discussion This image will consider the device scale and find the right image
 */
+ (UIImage *)imageWithDictionary:(NSDictionary *)dictionary __attribute((deprecated("Use -imageWithJSONObject: instead")));

// Adds a light blur effect to a frame within the image, parse in the image frame to apply to whole image
- (UIImage *)applyLightEffectAtFrame:(CGRect)frame;

// Adds an extra light blur effect to a frame within the image, parse in the image frame to apply to whole image
- (UIImage *)applyExtraLightEffectAtFrame:(CGRect)frame;

// Adds a dark blur effect to a frame within the image, parse in the image frame to apply to whole image
- (UIImage *)applyDarkEffectAtFrame:(CGRect)frame;

// Adds a blur effect with a custom tint to a frame within the image, parse in the image frame to apply to whole image
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor atFrame:(CGRect)frame;

@end
