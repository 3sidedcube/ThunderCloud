//
//  TSCLogoListItemView.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 14/10/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCListItem.h"

@interface TSCLogoListItem : TSCListItem

@property (nonatomic, strong) NSString *logoTitle;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject;

@end
