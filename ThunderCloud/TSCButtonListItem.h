//
//  TSCButtonListItemView.h
//  ThunderStorm
//
//  Created by Simon Mitchell on 12/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCEmbeddedLinksListItem.h"

/**
 `TSCButtonListItem` is a subclass of TSCEmbeddedLinksListItem it reprents an item with a single button on it. It is rendered out as a `TSCEmbeddedLinksListItemCell`.
 */
@interface TSCButtonListItem : TSCEmbeddedLinksListItem

/**
 @abstract The id of the target on which to call the selector
 */
@property (nonatomic, weak) id target;

/**
 @abstract The method to call on the target when the button is selected
 */
@property (nonatomic, assign) SEL selector;

/**
 Initializes a new instance of `TSCButtonListItem`
 @param target An id of the target on which to call the selector
 @param aSelector The method to call on the target when the button is selected
 */
- (instancetype)initWithTarget:(id)target selector:(SEL)aSelector;

/**
 Set the dataSource of the table view to reload with the new content
 @param title The `UIButton`s title
 @param buttonTitle The `UIButton`s title
 @param target An id of the target on which to call the selector
 @param aSeclector The method to call on the target when the button is selected
 */
+ (instancetype)itemWithTitle:(NSString *)title buttonTitle:(NSString *)buttonTitle target:(id)target selector:(SEL)aSeclector;

@end