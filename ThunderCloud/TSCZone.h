//
//  TSCArea.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 14/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@import Foundation;
@import CoreGraphics;

@interface TSCZone : NSObject

@property (nonatomic, strong) NSMutableArray *coordinates;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (BOOL)containsPoint:(CGPoint)point;

@end
