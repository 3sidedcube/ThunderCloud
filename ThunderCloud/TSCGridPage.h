//
//  TSCGridPage.h
//  ASPCA
//
//  Created by Matt Cheetham on 27/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSCCollectionViewController.h"
#import "TSCGridItem.h"

@class TSCGridPage;

/**
 A subclass of `TSCCollectionViewController` for displaying a CMS grid page
 */
@interface TSCGridPage : TSCCollectionViewController

/**
 Initializes a new instance using a CMS representation of a grid page
 @param dictionary The dictionary to be used to initialize and populate the view controller
 */
- (id)initWithDictionary:(NSDictionary *)dictionary;

/**
 @abstract The items which are being displayed in the grid
 */
@property (nonatomic, strong, readonly) NSMutableArray *gridItems;

/**
 @abstract The currently selected grid item
 */
@property (nonatomic, strong, readonly) TSCGridItem *selectedGridItem;

@end