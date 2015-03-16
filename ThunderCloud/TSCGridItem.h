//
//  TSCGridItem.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 27/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSCGridItem : NSObject

@property (nonatomic, copy) NSString *itemClass;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *itemDescription;
@property (nonatomic, strong) NSDictionary *link;
@property (nonatomic, strong) NSDictionary *image;
@property (nonatomic, copy) NSString *badgeId;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
