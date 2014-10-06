//
//  TSCAppCollectionItem.h
//  ThunderCloud
//
//  Created by Matt Cheetham on 26/06/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

@class TSCAppIdentity;

@import Foundation;
@import UIKit;

@interface TSCAppCollectionItem : NSObject

@property (nonatomic, strong) UIImage *appIcon;
@property (nonatomic, strong) TSCAppIdentity *appIdentity;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
