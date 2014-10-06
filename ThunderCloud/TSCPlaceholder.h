//
//  TSCPlaceholder.h
//  ThunderStorm
//
//  Created by Andrew Hart on 02/01/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

@import UIKit;

@interface TSCPlaceholder : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *placeholderDescription;
@property (nonatomic, strong) UIImage *image;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
