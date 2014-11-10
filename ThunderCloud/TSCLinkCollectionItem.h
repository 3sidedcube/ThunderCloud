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

@interface TSCLinkCollectionItem : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) TSCLink *link;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
