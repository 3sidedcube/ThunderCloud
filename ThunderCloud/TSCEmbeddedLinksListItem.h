//
//  TSCEmbeddedLinksListItem.h
//  ThunderCloud
//
//  Created by Simon Mitchell on 28/10/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

#import "TSCListItem.h"

/**
 `TSCEmbeddedLinksListItem` is a `TSCListItem` that allows embedded links. Each link is displayed as a button.
 */
@interface TSCEmbeddedLinksListItem : TSCListItem

/**
 @abstract An array `TSCLink`s to display
 */
@property NSArray *embeddedLinks;

@end
