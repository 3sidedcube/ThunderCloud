//
//  TSCCoordinate.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 14/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@import UIKit;

@interface TSCCoordinate : NSObject

- (id)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic) CGFloat x, y, z;

@end
