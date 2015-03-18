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
@import ThunderBasics;
#import "TSCImageRepresentation.h"
#import "TSCLink.h"

@implementation TSCImage

+ (UIImage *)imageWithJSONObject:(NSObject *)object
{
    if ([object isKindOfClass:[NSArray class]]) {
        
        return [TSCImage imageWithArray:(NSArray *)object];
        
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        
        return [TSCImage imageWithDictionary:(NSDictionary *)object];
        
    }
    
    return nil;
}

+ (UIImage *)imageWithDictionary:(NSDictionary *)dictionary
{
    if ([dictionary isKindOfClass:[NSArray class]]) {
        
        return [TSCImage imageWithArray:(NSArray *)dictionary];
        
    }
    if (dictionary != (id)[NSNull null]) {
        
        NSString *imageClass = dictionary[@"class"];
        
        //Old image style
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

+ (UIImage *)imageWithArray:(NSArray *)array
{
    if ([array isKindOfClass:[NSDictionary class]]) {
        
        return [TSCImage imageWithDictionary:(NSDictionary *)array];
        
    }
    
    NSArray *imageRepresentations = [NSArray arrayWithArrayOfDictionaries:array rootInstanceType:[TSCImageRepresentation class]];
    
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    
    if (screenScale == 3.0) {
        
        TSCImageRepresentation *imageRepresentation = [imageRepresentations lastObject];
        
        return [TSCImage imageForCacheURL:imageRepresentation.sourceLink.url scale:screenScale];
        
    }
    
    if (screenScale == 1.0) {
        
        TSCImageRepresentation *imageRepresentation = [imageRepresentations firstObject];
        
        return [TSCImage imageForCacheURL:imageRepresentation.sourceLink.url scale:screenScale];
        
    }
    
    NSInteger middleValue = ceil((double)imageRepresentations.count / 2);
    TSCImageRepresentation *imageRepresentation = imageRepresentations[middleValue - 1];
    return [TSCImage imageForCacheURL:imageRepresentation.sourceLink.url scale:screenScale];
}

+ (UIImage *)imageForCacheURL:(NSURL *)cacheURL scale:(CGFloat)scale
{
    NSString *imagePath = [[TSCContentController sharedController] pathForCacheURL:cacheURL];
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    return [UIImage imageWithData:imageData scale:scale];
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
