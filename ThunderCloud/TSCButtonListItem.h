//
//  TSCButtonListItemView.h
//  ThunderStorm
//
//  Created by Simon Mitchell on 12/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCEmbeddedLinksListItem.h"

@interface TSCButtonListItem : TSCEmbeddedLinksListItem

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;

- (instancetype)initWithTarget:(id)target selector:(SEL)aSelector;
+ (instancetype)itemWithTitle:(NSString *)title buttonTitle:(NSString *)buttonTitle target:(id)target selector:(SEL)aSeclector;

@end