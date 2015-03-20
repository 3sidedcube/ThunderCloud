//
//  TSCLinkCollectionItem.h
//  ThunderCloud
//
//  Created by Simon Mitchell on 27/10/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@class TSCLink;

/**
 A object representation of a Link collection item, has an associated `UIImage` and `TSCLink`
 */
@interface TSCLinkCollectionItem : NSObject

/**
 Initializes a new instance of `TSCLinkCollectionItem` from a CMS representation
 @param dictionary The dictionary to initialize and populate the link from
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 @abstract The image to be displayed for the link
 */
@property (nonatomic, strong) UIImage *image;

/**
 @abstract The link of the link...
 */
@property (nonatomic, strong) TSCLink *link;

@end
