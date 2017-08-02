//
//  TSCImage.m
//  ThunderStorm
//
//  Created by Phillip Caudell on 10/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCImage.h"
#import "ThunderCloud/ThunderCloud-Swift.h"
@import ThunderBasics;
#import "TSCImageRepresentation.h"
#import "TSCLink.h"
#import "TSCStormLanguageController.h"

@implementation TSCImage

+ (UIImage *)imageWithJSONObject:(NSObject *)object
{
    if ([object isKindOfClass:[NSArray class]]) {
        
        return [TSCImage imageWithArray:(NSArray *)object];
        
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        return [TSCImage imageWithDictionary:(NSDictionary *)object];
        #pragma clang diagnostic pop
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
            
            if ([self assetsImageWithURL:imageURL]) {
                return [self assetsImageWithURL:imageURL];
            }
            
            NSURL *imagePath = [[TSCContentController sharedController] urlForCacheURL:imageURL];
            
            if (imagePath) {
                NSData *imageData = [NSData dataWithContentsOfURL:imagePath];
                UIImage *image = [UIImage imageWithData:imageData scale:scale];
                
                return image;
            } else {
                return nil;
            }
        }
    }
    
    return nil;
}

+ (UIImage *)assetsImageWithURL:(NSURL *)imageURL {
    
    if (imageURL) {
        
        NSString *thinnedAssetName = imageURL.absoluteString.lastPathComponent;
        NSString *lastUnderscoreComponent = [thinnedAssetName componentsSeparatedByString:@"_"].lastObject;
        
        if (![lastUnderscoreComponent isEqualToString:thinnedAssetName] && ([lastUnderscoreComponent containsString:@".png"] || [lastUnderscoreComponent containsString:@".jpg"])) {
            thinnedAssetName = [thinnedAssetName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"_%@",lastUnderscoreComponent] withString:@""];
        }
        
        if ([UIImage imageNamed:thinnedAssetName]) {
            return [UIImage imageNamed:thinnedAssetName];
        }
    }
    
    return nil;
}

+ (UIImage *)imageWithArray:(NSArray *)array
{
    if ([array isKindOfClass:[NSDictionary class]]) {
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        return [TSCImage imageWithDictionary:(NSDictionary *)array];
        #pragma clang diagnostic pop
    }
    
    NSArray *allAvailableImageRepresentations = [NSArray arrayWithArrayOfDictionaries:array rootInstanceType:[TSCImageRepresentation class]];
    
    NSArray *imagesWithCompatibleMimeTypes = [TSCImage imagesWithCompatibleMimeTypeInArray:allAvailableImageRepresentations];
    
    NSArray *availableImagesForLocale = [TSCImage compatibleImagesInArray:imagesWithCompatibleMimeTypes forLocaleString:[TSCStormLanguageController sharedController].currentLanguage];
    
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    
    if (screenScale == 3.0) {
        
        TSCImageRepresentation *imageRepresentation = [availableImagesForLocale lastObject];
        
        if (imageRepresentation && imageRepresentation.sourceLink) {
            return [TSCImage imageForCacheURL:imageRepresentation.sourceLink.url scale:screenScale];
        }
        
    }
    
    if (screenScale == 1.0) {
        
        TSCImageRepresentation *imageRepresentation = [availableImagesForLocale firstObject];
        
        if (imageRepresentation && imageRepresentation.sourceLink) {
            return [TSCImage imageForCacheURL:imageRepresentation.sourceLink.url scale:screenScale];
        }
        
    }
    
    NSInteger middleValue = ceil((double)availableImagesForLocale.count / 2);
    TSCImageRepresentation *imageRepresentation = availableImagesForLocale[middleValue - 1];
    
    if (imageRepresentation && imageRepresentation.sourceLink) {

        if([imageRepresentation.sourceLink.linkClass isEqualToString:@"InternalLink"]) {
            return [TSCImage imageForCacheURL:imageRepresentation.sourceLink.url scale:screenScale];
        }
        
    }
    
    return nil;
}

+ (UIImage *)imageForCacheURL:(NSURL *)cacheURL scale:(CGFloat)scale
{
    if ([self assetsImageWithURL:cacheURL]) {
        return [self assetsImageWithURL:cacheURL];
    }
    
    NSURL *imagePath = [[TSCContentController sharedController] urlForCacheURL:cacheURL];
    
    if (imagePath) {
        NSData *imageData = [NSData dataWithContentsOfURL:imagePath];
        return [UIImage imageWithData:imageData scale:scale];
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

+ (NSArray *)compatibleImagesInArray:(NSArray *)imageRepresentationArray forLocaleString:(NSString *)stormLocaleString
{
    NSMutableArray *compatibleImages = [NSMutableArray array];
    
    for (TSCImageRepresentation *imageRepresentation in imageRepresentationArray) {
        
        if ([imageRepresentation.locale isEqualToString:stormLocaleString]) {
            
            [compatibleImages addObject:imageRepresentation];
            
        }
        
    }
    
    if(compatibleImages.count) {
    
        return compatibleImages;
        
    }
    
    return imageRepresentationArray;
}

+ (NSArray *)imagesWithCompatibleMimeTypeInArray:(NSArray *)array
{
    NSMutableArray *compatibleImageRepresentations = [NSMutableArray array];
    
    for (TSCImageRepresentation *representation in array) {
        
        if ([TSCImage canDisplayImageWithMimeType:representation.mimeType]) {
            
            [compatibleImageRepresentations addObject:representation];
            
        }
        
    }
    
    return compatibleImageRepresentations;
}

+ (BOOL)canDisplayImageWithMimeType:(NSString *)mimeType
{
    NSArray *supportedMimeTypes = @[/* Tagged Image File Format (TIFF)*/
                                    @"image/tiff",
                                    @"image/x-tiff",
                                    /* Joint Photographic Experts Group (JPEG)*/
                                    @"image/jpeg",
                                    @"image/pjpeg",
                                    /* Graphic Interchange Format (GIF)*/
                                    @"image/gif",
                                    /* Portable Network Graphic (PNG)*/
                                    @"image/png",
                                    /* Windows Bitmap Format (DIB)*/
                                    @"image/bmp",
                                    @"image/x-windows-bmp",
                                    /* Windows Icon Format && Windows Cursor*/
                                    @"image/x-icon",
                                    /* X Window System bitmap*/
                                    @"image/xbm",
                                    @"image/x-xbm",
                                    @"image/x-xbitmap",
                                    ];
    
    for (NSString *supportedMimeType in supportedMimeTypes) {
        
        if ([mimeType.lowercaseString isEqualToString:supportedMimeType]) {
            
            return YES;
        }
        
    }
    
    return NO;
}

@end
