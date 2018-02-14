//
//  TSCGridItem.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 27/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

/**
 A model representation of a CMS grid item to be displayed in a 'grid' or `UICollectionView`
 */
@interface TSCGridItem : NSObject

/**
 Initializes a new grid item from a CMS representation of a grid object
 @param dictionary The dictionary to initialize and populate the grid item from
 */
- (id)initWithDictionary:(NSDictionary *)dictionary;

/**
 @abstract Keeps track of the cell class to be used when displaying this grid item in a `UICollectionView`
 */
@property (nonatomic, copy) NSString *itemClass;

/**
 @abstract The title to be displayed when displaying this item in a `UICollectionView`
 */
@property (nonatomic, copy) NSString *title;

/**
 @abstract The description to be displayed when displaying this item in a `UICollectionView`
 */
@property (nonatomic, copy) NSString *itemDescription;

/**
 @abstract The link to be pushed or presented when a user selects this grid item
 */
@property (nonatomic, strong) NSDictionary *link;

/**
 @abstract The image to be displayed when displaying this item in a `UICollectionView`
 */
@property (nonatomic, strong) UIImage *image;

/**
 @abstract The badge id associated with this grid item
 */
@property (nonatomic, copy) NSString *badgeId;

@end
