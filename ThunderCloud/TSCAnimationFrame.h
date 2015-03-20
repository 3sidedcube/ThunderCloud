//
//  TSCAnimationFrame.h
//  ThunderCloud
//
//  Created by Matthew Cheetham on 20/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSCImage.h"

@interface TSCAnimationFrame : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, strong) NSNumber *delay;
@property (nonatomic, strong) UIImage *image;

@end
