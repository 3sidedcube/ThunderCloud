//
//  TSCLogoListItemView.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 14/10/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCListItem.h"

/**
 `TSCLogoListItem` is a subclass of TSCListItem it is used to display company logos inside of an app. It is rendered out as a `TSCLogoListItemViewCell`.
 */
@interface TSCLogoListItem : TSCListItem

/**
 @abstract The title that sits underneath the logo
 */
@property (nonatomic, copy) NSString *logoTitle;

/**
 Initialises the `TSCLogoListItem` object with an array of information provided by Storm
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject;

@end
