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
 Returns the item size to display the cells at
 */
- (CGSize)itemSizeForCells;

/**
 @abstract The items which are being displayed in the grid
 */
@property (nonatomic, strong, readonly) NSMutableArray *gridItems;

/**
 @abstract The number of columns which should be displayed in the grid
 */ 
@property (nonatomic) NSInteger numberOfColumns;

/**
 @abstract The currently selected grid item
 */
@property (nonatomic, strong) TSCGridItem *selectedGridItem;

/**
 @abstract An array of classes registered to cells in the `UICollectionView`
 */
@property (nonatomic, strong) NSMutableArray *registeredCellClasses;

/**
 @abstract A method to configure a cell for a certain index path
 @param cell The cell to configure
 @param indexPath the index path of the cell to configure
 */
- (void)configureCell:(UICollectionViewCell *)cell withIndexPath:(NSIndexPath *)indexPath;

/**
 @abstract The unique identifier for the storm page
 */
@property (nonatomic, copy) NSString *pageId;

/**
 @abstract The internal name for this page. Named pages can be used for native overrides and for identifying pages that may change with delta publishes. By default pages do not have names but they can be added in the CMS
 */
@property (nullable, nonatomic, copy) NSString *pageName;

@end