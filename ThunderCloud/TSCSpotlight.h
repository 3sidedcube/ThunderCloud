//
//  TSCSpotlight.h
//  ThunderCloud
//
//  Created by Matthew Cheetham on 20/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

@import Foundation;
@import UIKit;
#import "TSCStormObject.h"

@class TSCLink;

@interface TSCSpotlight : TSCStormObject

/**
 @abstract A `UIImage` that is displayed for the spolight
 */
@property (nonatomic, strong) UIImage *image;

/**
 @abstract A `TSCLink` used to perform an action when an item is selected
 */
@property (nonatomic, strong) TSCLink *link;

/**
 @abstract An Interger of time to determine how long the item is displayed on screen for
 */
@property (assign) NSInteger delay;

/**
 @abstract A string of text that is displayed across the center of the spotlight item
 */
@property (nonatomic, copy) NSString *spotlightText;

@end
