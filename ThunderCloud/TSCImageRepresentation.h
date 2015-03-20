//
//  TSCImageRepresentation.h
//  ThunderCloud
//
//  Created by Matthew Cheetham on 17/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

@import Foundation;
@import CoreGraphics;
@class TSCLink;

/**
 An object representation of an image. This class is used to represent one image in array of possible images that the app can use. The image representation will be used in a lookup after determining the devices screen density
 */
@interface TSCImageRepresentation : NSObject

/**
 A link to the image in the bundle
 */
@property (nonatomic, strong) TSCLink *sourceLink;

/**
 The dimensions of the image represented as a CGSize
 */
@property (nonatomic, assign) CGSize dimensions;

/**
 The mime type of the image, can be used to check if the image is compatible with the device
 */
@property (nonatomic, copy) NSString *mimeType;

/**
 The byte size of the file.
 */
@property (nonatomic, strong) NSNumber *byteSize;

/**
 The storm locale of the image. Images may be localised in the future, so pay attention
 */
@property (nonatomic, strong) NSString *locale;

@end
