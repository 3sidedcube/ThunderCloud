//
//  TSCInlineButton.h
//  ThunderStorm
//
//  Created by Andrew Hart on 12/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@class TSCLink;

@import ThunderBasics;

@interface TSCInlineButton : TSCObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) TSCLink *link;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) NSString *pageLink;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end