//
//  TSCAnimation.h
//  ThunderCloud
//
//  Created by Matthew Cheetham on 20/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A representation of an animated image. Contains information about the frames and whether or not the GIF is looped
 */
@interface TSCAnimation : NSObject

/**
 Initialises a new instance of a `TSCAnimation` using a storm dictionary object
 @param dictionary A storm dictionary with animation information
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 @abstract The array of `TSCAnimationFrame`s that are a part of the animation
 */
@property (nonatomic, strong) NSArray *animationFrames;

/**
 @abstract A boolean indicating whether or not the GIF should loop once played
 */
@property (nonatomic, assign) BOOL looped;

@end
