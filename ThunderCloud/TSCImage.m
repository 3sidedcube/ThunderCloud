//
//  TSCImage.m
//  ThunderStorm
//
//  Created by Phillip Caudell on 10/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCImage.h"
#import "UIImage+ImageEffects.h"
#import "TSCContentController.h"

@implementation TSCImage

+ (UIImage *)imageWithDictionary:(NSDictionary *)dictionary
{
    if (dictionary != (id)[NSNull null]) {
        
        NSString *imageClass = dictionary[@"class"];
        
        if ([imageClass isEqualToString:@"NativeImage"]) {
            
            NSURL *imageURL = [NSURL URLWithString:dictionary[@"src"]];
            NSString *fileName = [imageURL lastPathComponent];
            
            UIImage *nativeImage = [UIImage imageNamed:fileName];
            
            return nativeImage;
            
        } else {
            CGFloat scale = [[UIScreen mainScreen] scale];
            
            if (scale == 3.0) {
                scale = 2.0;
            }
            
            NSString *imageScaleKey = @"x2";
            
            if (scale == 1.0) {
                imageScaleKey = @"x1";
            }
            
            NSURL *imageURL = [NSURL URLWithString:dictionary[@"src"][imageScaleKey]];
            NSString *imagePath = [[TSCContentController sharedController] pathForCacheURL:imageURL];
            NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
            UIImage *image = [UIImage imageWithData:imageData scale:scale];
            
            return image;
        }
    }
    
    return nil;
}

- (UIImage *)croppedImageAtFrame:(CGRect)frame
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], frame);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropped;
}

- (UIImage *)addImageToImage:(UIImage *)img atRect:(CGRect)cropRect
{
    CGSize size = CGSizeMake(self.size.width, self.size.height);
    UIGraphicsBeginImageContext(size);
    
    CGPoint pointImg1 = CGPointMake(0, 0);
    [self drawAtPoint:pointImg1];
    
    CGPoint pointImg2 = cropRect.origin;
    [img drawAtPoint:pointImg2];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

- (UIImage *)applyLightEffectAtFrame:(CGRect)frame
{
    UIImage *blurredFrame = [[self croppedImageAtFrame:frame] applyLightEffect];
    
    return [self addImageToImage:blurredFrame atRect:frame];
}

- (UIImage *)applyExtraLightEffectAtFrame:(CGRect)frame
{
    UIImage *blurredFrame = [[self croppedImageAtFrame:frame] applyExtraLightEffect];
    
    return [self addImageToImage:blurredFrame atRect:frame];
}

- (UIImage *)applyDarkEffectAtFrame:(CGRect)frame
{
    UIImage *blurredFrame = [[self croppedImageAtFrame:frame] applyDarkEffect];
    
    return [self addImageToImage:blurredFrame atRect:frame];
}

- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor atFrame:(CGRect)frame
{
    UIImage *blurredFrame = [[self croppedImageAtFrame:frame] applyTintEffectWithColor:tintColor];
    
    return [self addImageToImage:blurredFrame atRect:frame];
}

@end
